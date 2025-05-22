// lib/pages/login_logic.dart

class LoginValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira seu email';
    }

    // Regex simples para validar email
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira sua senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }
}
