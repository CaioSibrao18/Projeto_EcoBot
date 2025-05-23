// resetPassword_logic.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordService {
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String novaSenha,
  }) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'token': token.trim(),
        'nova_senha': novaSenha.trim(),
      }),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Senha alterada com sucesso!',
      };
    } else {
      return {
        'success': false,
        'message': responseData['error'] ?? responseData['message'] ?? 'Erro ao redefinir senha',
      };
    }
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Campo obrigatório';
    if (password.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? validateRequiredField(String value) {
    if (value.isEmpty) return 'Campo obrigatório';
    return null;
  }

  static bool passwordsMatch(String senha1, String senha2) {
    return senha1 == senha2;
  }
}
