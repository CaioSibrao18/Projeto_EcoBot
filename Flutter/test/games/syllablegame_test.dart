import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/syllablegame.dart';

void main() {
  testWidgets('SpellingGameSyllables - renderiza, interage e reseta', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SpellingGameSyllables(),
      ),
    );

    // Verifica textos e sílabas iniciais na tela
    expect(find.text('Arraste as sílabas para formar a palavra:'), findsOneWidget);

    // Syllables iniciais da primeira palavra: 'ga', 'to', 'la'
    expect(find.text('ga'), findsOneWidget);
    expect(find.text('to'), findsOneWidget);
    expect(find.text('la'), findsOneWidget);

    // Verifica botões existem
    final confirmarBtn = find.text('Confirmar');
    final limparBtn = find.text('Limpar');

    expect(confirmarBtn, findsOneWidget);
    expect(limparBtn, findsOneWidget);

    // Tenta clicar no botão Confirmar (sem selecionar sílabas)
    await tester.tap(confirmarBtn);
    await tester.pump(const Duration(seconds: 1)); // aguarda animação

   
    expect(find.text(''), findsWidgets); 

    // Agora clica no botão Limpar para resetar
    await tester.tap(limparBtn);
    await tester.pump();

    // Após reset, a lista de sílabas selecionadas deve continuar vazia
    expect(find.text(''), findsWidgets);
  });
}
