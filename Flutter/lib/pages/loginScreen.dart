import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registerScreen.dart';
import 'forgetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('http://localhost:5000/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim().toLowerCase(),
          'senha': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/menu_games');
      } else {
        setState(() {
          _errorMessage = responseData['error'] ?? 'Usuário ou senha inválidos';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao conectar com o servidor';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/telaFundo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoEcoQuest.png',
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 20),

                  // Campo de Email
                  Container(
                    width: 300,
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
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Color(0xFF2BB462)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        errorStyle: TextStyle(height: 0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    width: 300,
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
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Senha',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF2BB462)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        errorStyle: TextStyle(height: 0),
                      ),
                    ),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 40),
                  SizedBox(
                    height: 40,
                    width: 170,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                                strokeWidth: 2,
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ForgetPasswordScreen(),
                                ),
                              );
                            },
                    child: const Text('Esqueci a senha'),
                  ),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                    child: const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
