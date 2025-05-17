import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_tokenController.text.isEmpty ||
          _newPasswordController.text.isEmpty ||
          widget.email.isEmpty) {
        throw Exception('Preencha todos os campos');
      }

      final response = await http.post(
        Uri.parse('http://localhost:5000/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email.trim(),
          'token': _tokenController.text.trim(),
          'nova_senha': _newPasswordController.text.trim(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Senha alterada com sucesso!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['error'] ??
                  responseData['message'] ??
                  'Erro ao redefinir senha ${response.statusCode})',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/TelaFundo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 50),
                            const Text(
                              'Redefinir Senha',
                              style: TextStyle(
                                fontFamily: 'ReemFufiFun[wght]',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Para: ${widget.email}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(66, 0, 51, 0),
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _tokenController,
                                decoration: const InputDecoration(
                                  hintText: 'Token de verificação',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(1.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o token';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(66, 0, 51, 0),
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Nova senha (mínimo 6 caracteres)',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(1.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira a nova senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(66, 0, 51, 0),
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscurePassword,
                                decoration: const InputDecoration(
                                  hintText: 'Confirmar nova senha',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(1.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, confirme a senha';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 35),
                            SizedBox(
                              height: 40,
                              width: 170,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2BB462),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          'Redefinir Senha',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.pop(context);
                                      },
                              child: const Text(
                                'Voltar',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
