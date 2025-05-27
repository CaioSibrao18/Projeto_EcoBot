import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ecoquest/pages/forgetPasswordScreen.dart';

@GenerateMocks([http.Client])
import 'widget_forget_password_screen_test.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: ForgetPasswordScreen(client: mockClient));
  }

  testWidgets('Envia e-mail com sucesso e navega para próxima tela', (
    tester,
  ) async {
    when(
      mockClient.post(
        Uri.parse('http://localhost:5000/forget-password'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => http.Response('{}', 200));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField), 'teste@email.com');
    await tester.tap(find.text('Enviar E-mail'));
    await tester.pumpAndSettle();

    expect(find.text('Esqueci minha senha'), findsNothing);
  });

  testWidgets('Exibe mensagem de erro se resposta for 400', (tester) async {
    when(
      mockClient.post(
        Uri.parse('http://localhost:5000/forget-password'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer(
      (_) async =>
          http.Response(jsonEncode({'error': 'E-mail não encontrado'}), 400),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField), 'erro@email.com');
    await tester.tap(find.text('Enviar E-mail'));
    await tester.pump(); // deixar a SnackBar aparecer

    expect(find.text('E-mail não encontrado'), findsOneWidget);
  });

  testWidgets('Formulário inválido não envia requisição', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Enviar E-mail'));
    await tester.pump();

    expect(find.text('Insira seu e-mail'), findsOneWidget);
    verifyNever(
      mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    );
  });
}
