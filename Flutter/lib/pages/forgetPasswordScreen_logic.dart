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

      print('DEBUG :: statusCode: ${response.statusCode}');
      print('DEBUG :: body: ${response.body}');

      final dynamic decoded = json.decode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Resposta inesperada do servidor',
        };
      }

      final data = decoded;
      final mensagem = data['mensagem'] ?? 'Verifique seu e-mail';
      final status = data['status']?.toString().toLowerCase();

      if (response.statusCode == 200 && status == 'sucesso') {
        return {
          'success': true,
          'message': mensagem,
        };
      } else {
        return {
          'success': false,
          'message': mensagem,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
}
