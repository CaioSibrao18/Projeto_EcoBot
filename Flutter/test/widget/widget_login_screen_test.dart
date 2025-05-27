import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ecoquest/pages/loginScreen.dart';
import 'package:ecoquest/services/authe_service.dart';

@GenerateMocks([AuthService])
import 'widget_login_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authService: mockAuthService),
        routes: {
          '/menu_games': (context) => const Scaffold(body: Text('Menu Page')),
        },
      ),
    );
  }

  testWidgets('Login com sucesso redireciona para /menu_games', (tester) async {
    // Mock: login retorna sucesso
    when(mockAuthService.login(any, any)).thenAnswer(
      (_) async => http.Response(jsonEncode({'token': 'abc123'}), 200),
    );

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Verifica redirecionamento
    expect(find.text('Menu Page'), findsOneWidget);
  });

  testWidgets('Login com erro exibe mensagem', (tester) async {
    // Mock: login falha
    when(mockAuthService.login(any, any)).thenAnswer(
      (_) async => http.Response(jsonEncode({'error': 'Senha incorreta'}), 400),
    );

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Senha incorreta'), findsOneWidget);
  });

  testWidgets('Formulário inválido não chama login', (tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    verifyNever(mockAuthService.login(any, any));
    expect(find.text('Insira seu email'), findsOneWidget);
    expect(find.text('Insira sua senha'), findsOneWidget);
  });
}
