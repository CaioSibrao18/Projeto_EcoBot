import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/easytrash.dart';

void main() {
  group('Testes do EasyTrashSortingGame', () {
    testWidgets('Deve mostrar resultado final após completar todos itens', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EasyTrashSortingGame(),
        ),
      );

      // Acessa o estado diretamente (usando dynamic para evitar problemas com classe privada)
      final state = tester.state(find.byType(EasyTrashSortingGame)) as dynamic;
      
      // Configura estado como se tivesse respondido todos corretamente
      state.currentItemIndex = state.trashItems.length - 1;
      state.correctAnswers = state.trashItems.length;
      
      // Força mostrar o resultado
      state.showResult();
      await tester.pumpAndSettle();

      // Verifica diálogo de resultado
      expect(find.text('Fim do Jogo'), findsOneWidget);
      expect(
        find.text('Você acertou 100.0% dos objetos!'), 
        findsOneWidget,
        reason: 'Deveria mostrar 100% de acertos'
      );
      expect(find.text('Ótimo trabalho!'), findsOneWidget);
    });

    testWidgets('Deve reiniciar o jogo ao clicar em "Jogar Novamente"', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EasyTrashSortingGame(),
        ),
      );

      final state = tester.state(find.byType(EasyTrashSortingGame)) as dynamic;
      
      // Configura estado final
      state.currentItemIndex = state.trashItems.length - 1;
      state.correctAnswers = 3;
      
      // Mostra resultado
      state.showResult();
      await tester.pumpAndSettle();

      // Clica para reiniciar
      await tester.tap(find.text('Jogar Novamente'));
      await tester.pumpAndSettle();

      // Verifica se reiniciou
      expect(state.currentItemIndex, 0);
      expect(state.correctAnswers, 0);
      expect(find.text('Papel de caderno'), findsOneWidget);
    });
  });
}