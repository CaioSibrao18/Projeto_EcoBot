import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/services/authe_service.dart';
import 'package:ecoquest/pages/loginScreen.dart';
import 'package:http/http.dart' as http;

// Mock simples do AuthService
class MockAuthService implements AuthService {
  @override
  Future<http.Response> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (email == 'test@example.com' && password == 'senha123') {
      return http.Response('{"token": "abc123"}', 200);
    } else {
      return http.Response('{"error": "Usuário ou senha inválidos"}', 401);
    }
  }

  @override
  Future<http.Response> register(String name, String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> resetPassword(String email) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('Teste simples da tela de login', (tester) async {
    // Inicia a tela de login com mock do AuthService
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(authService: MockAuthService()),
      routes: {
        '/menu_games': (_) => const Scaffold(body: Text('Menu de Jogos')),
      },
    ));

    // Verifica se os campos principais estão na tela
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    // Validação de campos vazios
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Insira seu email'), findsOneWidget);
    expect(find.text('Insira sua senha'), findsOneWidget);

    // Login inválido
    await tester.enterText(find.byType(TextFormField).first, 'email@errado.com');
    await tester.enterText(find.byType(TextFormField).last, 'senhaerrada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Usuário ou senha inválidos'), findsOneWidget);

    // Login válido
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'senha123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Menu de Jogos'), findsOneWidget);
  });
}
