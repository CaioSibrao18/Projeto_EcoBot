import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resetPassword.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/forget-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim().toLowerCase(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ResetPasswordScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['error'] ?? 'Erro ao enviar email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: ${e.toString()}'),
          backgroundColor: Colors.red,
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
                            Text(
                              'Esqueci minha senha',
                              style: const TextStyle(
                                fontFamily: 'ReemFufiFun[wght]',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 35),
                            const Text(
                              'Digite seu e-mail no campo abaixo\npara receber um token de redefinição.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 85),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email inválido';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'E-mail',
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
                              ),
                            ),
                            const SizedBox(height: 60),
                            SizedBox(
                              height: 40,
                              width: 170,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _sendResetEmail,
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
                                          'Enviar E-mail',
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
                                'Voltar a tela de login',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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
