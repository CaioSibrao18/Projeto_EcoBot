import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/quizhard.dart';

void main() {
  testWidgets('QuizScreenHard - interação básica', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreenHard(),
      ),
    );

    // Verifica se a primeira pergunta aparece
    expect(find.text('A lata amarela é destinada a qual tipo de lixo?'), findsOneWidget);

    // Verifica se as opções aparecem
    expect(find.text('Papel'), findsOneWidget);
    expect(find.text('Vidro'), findsOneWidget);

    // Clica em uma resposta errada (exemplo: índice 0 -> 'Papel', correta é índice 3)
    await tester.tap(find.text('Papel'));
    await tester.pump();

    // O botão selecionado deve ficar vermelho (opção errada)
    final papelButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Papel'));
    expect((papelButton.style?.backgroundColor?.resolve({}))!, Colors.red);

    // O botão da resposta correta deve ficar verde
    final corretoButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Metal'));
    expect((corretoButton.style?.backgroundColor?.resolve({}))!, Colors.green);

    // Aguarda 2 segundos para passar para a próxima pergunta
    await tester.pump(const Duration(seconds: 2));

    // Verifica que a segunda pergunta aparece
    expect(find.text('Quanto tempo leva para o papel sumir no meio ambiente?'), findsOneWidget);
  });
}
