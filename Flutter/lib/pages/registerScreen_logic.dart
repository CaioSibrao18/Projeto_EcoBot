// lib/pages/registerScreen_logic.dart

class RegisterValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Insira seu nome';
    }
    return null;
  }

  static String? validateBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.trim().isEmpty) {
      return 'Insira sua data de nascimento';
    }
    return null;
  }

  static String? validateGender(String? gender) {
    if (gender == null) {
      return 'Selecione seu gênero';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Insira seu email';
    }
    if (!email.contains('@')) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Insira sua senha';
    }
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirme sua senha';
    }
    if (password != confirmPassword) {
      return 'As senhas não coincidem';
    }
    return null;
  }
}
