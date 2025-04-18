import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'loginScreen.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoEcoQuest.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              _inputField(_nameController, 'Nome', Icons.person),
              const SizedBox(height: 20),
              _datePickerField(),
              const SizedBox(height: 15),
              _dropdownGenderField(),
              const SizedBox(height: 15),
              _inputField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 15),
              _inputField(
                _passwordController,
                'Senha',
                Icons.lock,
                obscure: true,
              ),
              const SizedBox(height: 15),
              _inputField(
                _confirmPasswordController,
                'Confirmar Senha',
                Icons.lock,
                obscure: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      // Aqui vai a lógica de cadastro
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cadastro realizado com sucesso!'),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('As senhas não coincidem.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BB462),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Já tem uma conta? Faça login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2BB462)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Color(0xFF2BB462), width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _dropdownGenderField() {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        items: const [
          DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Gênero',
          prefixIcon: const Icon(Icons.person, color: Color(0xFF2BB462)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Color(0xFF2BB462), width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _datePickerField() {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _birthController,
        readOnly: true,
        keyboardType: TextInputType.none,
        decoration: InputDecoration(
          labelText: 'Data de Nascimento',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF2BB462),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Color(0xFF2BB462), width: 2.0),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode()); // Esconde o teclado
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2005, 1),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            locale: const Locale("pt", "BR"),
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
            setState(() {
              _birthController.text = formattedDate;
            });
          }
        },
      ),
    );
  }
}
