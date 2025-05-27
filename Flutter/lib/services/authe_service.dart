import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class AuthService {
  Future<http.Response> login(String email, String senha);
}

class AuthServiceImpl implements AuthService {
  @override
  Future<http.Response> login(String email, String senha) {
    final url = Uri.parse('http://localhost:5000/auth/login');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email.toLowerCase(), 'senha': senha}),
    );
  }
}
