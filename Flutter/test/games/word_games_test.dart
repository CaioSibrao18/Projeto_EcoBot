import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/wordgame.dart';

void main() {
  testWidgets('Teste básico SpellingGameLetters', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SpellingGameLetters()));

    expect(find.text('Soletrar por Letras'), findsOneWidget);
    expect(find.text('Monte a palavra corretamente:'), findsOneWidget);
    expect(find.text('Palavra 1 de 10'), findsOneWidget);

    final confirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    final limpar = find.widgetWithText(ElevatedButton, 'Limpar');

    expect(confirmar, findsOneWidget);
    expect(limpar, findsOneWidget);

    // Toca no botão confirmar
    await tester.tap(confirmar);
    await tester.pump(); // Atualiza a UI

    // Espera o Timer acabar (1 segundo + margem)
    await tester.pump(const Duration(seconds: 2));

    // Verifica que o widget ainda está montado
    expect(find.text('Soletrar por Letras'), findsOneWidget);
  });
}
