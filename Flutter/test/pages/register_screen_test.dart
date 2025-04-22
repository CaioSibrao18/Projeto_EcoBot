import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/registerScreen.dart';


void main() {
  testWidgets('Componentes da tela de cadastro aparecem corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    // Verifica se existem 4 campos de texto
    expect(find.byType(TextField), findsNWidgets(4));

    // Verifica se o botão "Cadastrar" aparece
    expect(find.text('Cadastrar'), findsOneWidget);

    // Verifica se o botão de redirecionar para login aparece
    expect(find.text('Já tem uma conta? Faça login'), findsOneWidget);
  });

  testWidgets('Exibe mensagem de erro se as senhas não coincidirem', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'João');
    await tester.enterText(find.byType(TextField).at(1), 'joao@email.com');
    await tester.enterText(find.byType(TextField).at(2), 'senha123');
    await tester.enterText(find.byType(TextField).at(3), 'outrasenha');

    await tester.tap(find.text('Cadastrar'));
    await tester.pump(); // Atualiza a tela para mostrar o SnackBar

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
  });

  testWidgets('Realiza cadastro com sucesso se senhas coincidirem', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
        routes: {
          '/login': (context) => const Placeholder(), // Simula login
        },
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Maria');
    await tester.enterText(find.byType(TextField).at(1), 'maria@email.com');
    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.enterText(find.byType(TextField).at(3), '123456');

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle(); // Espera transição

    // Verifica se SnackBar apareceu com sucesso
    expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);

    // Verifica se foi redirecionado (no seu caso vai pra LoginScreen, aqui estamos só simulando)
  });
}
