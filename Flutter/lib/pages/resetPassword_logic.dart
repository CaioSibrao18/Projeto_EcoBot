import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordResult {
  final bool success;
  final String message;

  ResetPasswordResult({required this.success, required this.message});
}

class ResetPasswordLogic {
  // Valida campos em branco
  static String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    return null;
  }

  // Valida tamanho mínimo da senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  // Valida se as senhas coincidem
  static String? validatePasswordsMatch(String password, String confirmPassword) {
    if (password != confirmPassword) return 'As senhas não coincidem';
    return null;
  }

  // Função que faz o reset da senha via HTTP
  // Retorna ResetPasswordResult com sucesso e mensagem
  static Future<ResetPasswordResult> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'token': token.trim(),
          'nova_senha': newPassword.trim(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ResetPasswordResult(
          success: true,
          message: responseData['message'] ?? 'Senha alterada com sucesso!',
        );
      } else {
        return ResetPasswordResult(
          success: false,
          message: responseData['error'] ??
              responseData['message'] ??
              'Erro ao redefinir senha',
        );
      }
    } catch (e) {
      return ResetPasswordResult(
        success: false,
        message: 'Erro: ${e.toString()}',
      );
    }
  }
}
