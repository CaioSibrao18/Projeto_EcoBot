import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/hardtrash.dart';

void main() {
  group('Testes do TrashSortingGame (Difícil)', () {
    testWidgets('Deve renderizar corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TrashSortingGame(),
        ),
      );

      // Verifica elementos iniciais
      expect(find.text('Jogo da Separação do Lixo - Difícil'), findsOneWidget);
      expect(find.text('Arraste o objeto para a lixeira correta:'), findsOneWidget);
      expect(find.text('Maçã mordida'), findsOneWidget);
      expect(find.text('VERDE'), findsOneWidget);
      expect(find.text('MARROM'), findsOneWidget);
      expect(find.text('AZUL'), findsOneWidget);
      expect(find.text('AMARELO'), findsOneWidget);
      expect(find.text('VERMELHO'), findsOneWidget);
    });

    testWidgets('Deve aceitar resposta correta (Maçã -> Marrom)', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TrashSortingGame(),
        ),
      );

      // Arrasta maçã para lixeira marrom
      await tester.drag(
        find.text('Maçã mordida'),
        tester.getCenter(find.text('MARROM')) - tester.getCenter(find.text('Maçã mordida')),
      );
      await tester.pumpAndSettle();

      // Verifica se avançou para o próximo item
      expect(find.text('Garrafa PET'), findsOneWidget);
    });

    testWidgets('Deve mostrar diálogo ao errar (Maçã -> Verde)', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TrashSortingGame(),
        ),
      );

      // Arrasta maçã para lixeira verde (errado)
      await tester.drag(
        find.text('Maçã mordida'),
        tester.getCenter(find.text('VERDE')) - tester.getCenter(find.text('Maçã mordida')),
      );
      await tester.pumpAndSettle();

      // Verifica diálogo de erro
      expect(find.text('Resposta Errada'), findsOneWidget);
      expect(find.text('A lixeira correta era a MARROM!'), findsOneWidget);
    });

    testWidgets('Deve mostrar resultado com 60% de acertos', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TrashSortingGame(),
        ),
      );

      // Acessa o estado de forma indireta
      final state = tester.state(find.byType(TrashSortingGame)) as dynamic;
      
      // Configura estado manualmente
      state.currentItemIndex = state.trashItems.length - 1;
      state.correctAnswers = 3; // 3 de 5 = 60%
      
      // Mostra resultado
      state.showResult();
      await tester.pumpAndSettle();

      // Verifica diálogo
      expect(find.text('Fim do Jogo'), findsOneWidget);
      expect(find.text('Você acertou 60.0% dos objetos!'), findsOneWidget);
      expect(find.text('Ótimo trabalho!'), findsOneWidget);
    });

    testWidgets('Deve reiniciar o jogo corretamente', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TrashSortingGame(),
        ),
      );

      final state = tester.state(find.byType(TrashSortingGame)) as dynamic;
      state.currentItemIndex = 3;
      state.correctAnswers = 2;
      
      state.showResult();
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Jogar Novamente'));
      await tester.pumpAndSettle();

      // Verifica se reiniciou
      expect(state.currentItemIndex, 0);
      expect(state.correctAnswers, 0);
      expect(find.text('Maçã mordida'), findsOneWidget);
    });
  });
}