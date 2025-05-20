import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/quizeasy.dart';

void main() {
  group('Testes simples do QuizScreenEasy', () {
    testWidgets('Deve mostrar a primeira pergunta', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreenEasy()));

      expect(find.text('Qual cor de lixeira é usada para plástico?'), findsOneWidget);
      expect(find.text('Pergunta 1 de 10'), findsOneWidget);
    });

    testWidgets('Deve responder uma pergunta e ir para próxima', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreenEasy()));

      await tester.tap(find.text('Vermelha')); // Resposta correta da primeira pergunta
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('O vidro pode ser reciclado?'), findsOneWidget);
      expect(find.text('Pergunta 2 de 10'), findsOneWidget);
    });

    testWidgets('Deve completar o quiz e reiniciar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreenEasy()));

      // Responde todas as 10 perguntas com a primeira opção (pode ser certa ou errada)
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(ElevatedButton).first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verifica resultado
      expect(find.text('Resultado'), findsOneWidget);
      expect(find.text('Reiniciar'), findsOneWidget);

      // Toca em reiniciar
      await tester.tap(find.text('Reiniciar'));
      await tester.pumpAndSettle();

      // Verifica que voltou para a primeira pergunta
      expect(find.text('Qual cor de lixeira é usada para plástico?'), findsOneWidget);
      expect(find.text('Pergunta 1 de 10'), findsOneWidget);
    });
  });
}
