import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/registerScreen.dart';

void main() {
  group('RegisterScreen', () {
    testWidgets('Exibe mensagem de erro quando as senhas são diferentes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'Caio'); // Nome
      await tester.enterText(find.byType(TextField).at(1), '01/01/2000'); // Data
      await tester.enterText(find.byType(TextField).at(2), 'caio@example.com'); // Email
      await tester.enterText(find.byType(TextField).at(3), '123456'); // Senha
      await tester.enterText(find.byType(TextField).at(4), 'abcdef'); // Confirmar senha diferente

      // Rola a tela até o botão
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(); // Espera animações do SnackBar

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
    });

    testWidgets('Exibe mensagem de sucesso e redireciona se senhas forem iguais', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'Caio'); // Nome
      await tester.enterText(find.byType(TextField).at(1), '01/01/2000'); // Data
      await tester.enterText(find.byType(TextField).at(2), 'caio@example.com'); // Email
      await tester.enterText(find.byType(TextField).at(3), '123456'); // Senha
      await tester.enterText(find.byType(TextField).at(4), '123456'); // Confirmar senha igual

      // Rola a tela até o botão
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(); // Espera o SnackBar e transições

      expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);
    });
  });
}
