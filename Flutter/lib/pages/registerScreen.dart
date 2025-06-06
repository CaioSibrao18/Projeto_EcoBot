import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registerScreen_logic.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('As senhas não coincidem', isError: true);
      return;
    }

    if (_selectedGender == null) {
      _showSnackBar('Selecione um gênero', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final birthDate = DateFormat('dd/MM/yyyy').parse(_birthController.text);
      final formattedDate = DateFormat('yyyy-MM-dd').format(birthDate);

      final response = await http.post(

        Uri.parse('http://localhost:5000/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': _nameController.text.trim(),
          'data_nascimento': formattedDate,
          'genero': _selectedGender == 'Masculino' ? 'M' : 'F',
          'email': _emailController.text.trim().toLowerCase(),
          'senha': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        _showSnackBar('Cadastro realizado com sucesso!');
        _clearForm();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showSnackBar(
          responseData['error'] ?? responseData['message'] ?? 'Erro no cadastro',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Erro de conexão: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _birthController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedGender = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: Stack(
        children: [
          ClipPath(
            clipper: RegisterCurveClipper(),
            child: Container(height: 250, color: const Color(0xFF2BB462)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logoEcoQuest.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      _inputField(
                        _nameController,
                        'Nome',
                        Icons.person,
                        validator: RegisterValidator.validateName,
                      ),
                      const SizedBox(height: 15),
                      _datePickerField(),
                      const SizedBox(height: 15),
                      _dropdownGenderField(),
                      const SizedBox(height: 15),
                      _inputField(
                        _emailController,
                        'Email',
                        Icons.email,
                        validator: RegisterValidator.validateEmail,
                      ),
                      const SizedBox(height: 15),
                      _inputField(
                        _passwordController,
                        'Senha',
                        Icons.lock,
                        obscure: true,
                        validator: RegisterValidator.validatePassword,
                      ),
                      const SizedBox(height: 15),
                      _inputField(
                        _confirmPasswordController,
                        'Confirmar Senha',
                        Icons.lock,
                        obscure: true,
                        validator: (value) =>
                            RegisterValidator.validateConfirmPassword(
                                _passwordController.text, value),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2BB462),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Já tem uma conta? Faça login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2BB462)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdownGenderField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: const [
        DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
        DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (value) => value == null ? 'Selecione um gênero' : null,
      decoration: InputDecoration(
        labelText: 'Gênero',
        prefixIcon: const Icon(Icons.person, color: Color(0xFF2BB462)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _datePickerField() {
    return TextFormField(
      controller: _birthController,
      readOnly: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        try {
          DateFormat('dd/MM/yyyy').parse(value);
        } catch (_) {
          return 'Data inválida';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Data de Nascimento',
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF2BB462)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year - 10),
          firstDate: DateTime(1900),
          lastDate: now,
        );
        if (pickedDate != null) {
          _birthController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      },
    );
  }
}

class RegisterCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
