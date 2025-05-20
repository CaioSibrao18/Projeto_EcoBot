import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/loginScreen.dart';

void main() {
  testWidgets('Componentes da tela de login aparecem corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Verifica se o campo de email está presente
    expect(find.byType(TextField), findsNWidgets(2)); 

    // Verifica se o botão de login aparece
    expect(find.text('Login'), findsOneWidget);

    // Verifica se o botão "Esqueci a senha" aparece
    expect(find.text('Esqueci a senha'), findsOneWidget);

    // Verifica se o logo é carregado
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Simula clique no botão de login', (WidgetTester tester) async {
    // Usa um MaterialApp com rotas simuladas
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
        routes: {
          '/menu_games': (context) => const Placeholder(), // Simula próxima tela
        },
      ),
    );

    // Clica no botão de login
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(); // Espera animações/rotas finalizarem

    // Verifica se redirecionou para a rota esperada
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
