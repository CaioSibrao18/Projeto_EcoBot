// forgetPasswordScreen_logic.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgetPasswordService {
  static String? validateEmail(String value) {
    if (value.isEmpty) return 'Insira seu e-mail';
    if (!value.contains('@')) return 'E-mail inválido';
    return null;
  }

  static Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final trimmedEmail = email.trim().toLowerCase();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/forget-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': trimmedEmail}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'E-mail enviado com sucesso'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Erro ao enviar e-mail'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: ${e.toString()}'};
    }
  }
}
