import 'dart:convert';
import 'package:http/http.dart' as http;

/// Interface abstrata para facilitar testes
abstract class IApiService {
  Future<String> enviarResultado({
    required int usuarioId,
    required int acertos,
    required int tempoSegundos,
  });
}

/// Implementação real que faz chamada HTTP
class ApiService implements IApiService {
  static const String baseUrl = 'http://localhost:5000';

  @override
  Future<String> enviarResultado({
    required int usuarioId,
    required int acertos,
    required int tempoSegundos,
  }) async {
    final url = Uri.parse('$baseUrl/saveResult');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'acertos': acertos,
          'tempo_segundos': tempoSegundos,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['message'];
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Erro desconhecido';
      }
    } catch (e) {
      return 'Erro de conexão: $e';
    }
  }
}
