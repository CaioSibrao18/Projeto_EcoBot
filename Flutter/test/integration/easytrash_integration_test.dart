import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/easytrash.dart';
import 'package:mockito/mockito.dart';
import '../mocks/easytrash_logic_test.mocks.dart';
import 'package:flutter/services.dart';

void main() {
  // Configuração inicial para carregar assets
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock dos assets
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter/assets'),
            (MethodCall methodCall) async {
          return Uint8List(0);
        });
  });

  testWidgets('TESTE DE SMOKE BÁSICO - Verifica se o widget é renderizado', 
      (WidgetTester tester) async {
    final mock = MockEasyTrashGameLogic();

    when(mock.getCurrentImage()).thenReturn('assets/images/revista.png');
    when(mock.getCorrectBinForCurrentItem()).thenReturn('azul');
    when(mock.getCurrentProgress()).thenReturn(1);
    when(mock.getTotalItems()).thenReturn(5);
    when(mock.isGameFinished()).thenReturn(false);
    when(mock.correctAnswers).thenReturn(0);
    when(mock.lastResultText).thenReturn(null);
    when(mock.lastResultBin).thenReturn(null);
    when(mock.lastResultCorrect).thenReturn(null);
    when(mock.trashItems).thenReturn([
      {'image': 'assets/images/revista.png', 'correctBin': 'azul'}
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: EasyTrashSortingGame(gameLogicOverride: mock),
      ),
    );

    expect(find.byType(EasyTrashSortingGame), findsOneWidget);
    expect(find.text('ARRASTE PARA A LIXEIRA CERTA'), findsOneWidget);
  });

  testWidgets('TESTE DE INTERAÇÃO - Verifica arrastar item para lixeira correta',
      (WidgetTester tester) async {
    final mock = MockEasyTrashGameLogic();

    when(mock.getCurrentImage()).thenReturn('assets/images/revista.png');
    when(mock.getCorrectBinForCurrentItem()).thenReturn('azul');
    when(mock.getCurrentProgress()).thenReturn(1);
    when(mock.getTotalItems()).thenReturn(5);
    when(mock.isGameFinished()).thenReturn(false);
    when(mock.correctAnswers).thenReturn(0);
    when(mock.lastResultText).thenReturn(null);
    when(mock.lastResultBin).thenReturn(null);
    when(mock.lastResultCorrect).thenReturn(null);
    when(mock.trashItems).thenReturn([
      {'image': 'assets/images/revista.png', 'correctBin': 'azul'}
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: EasyTrashSortingGame(gameLogicOverride: mock),
      )
    );

    // Encontra o widget Draggable
    final draggableFinder = find.byType(Draggable<String>);
    expect(draggableFinder, findsOneWidget);

    // Encontra o alvo de arraste (lixeira azul)
    final dragTargetFinder = find.byType(DragTarget<String>).first;
    expect(dragTargetFinder, findsOneWidget);

    // Realiza o arraste
    await tester.drag(draggableFinder, tester.getCenter(dragTargetFinder) - tester.getCenter(draggableFinder));
    await tester.pumpAndSettle();

    // Verifica se o método checkAnswer foi chamado
    verify(mock.checkAnswer('azul')).called(1);
  });

  testWidgets('TESTE DE ESTADO - Verifica mensagem de resultado correto',
      (WidgetTester tester) async {
    final mock = MockEasyTrashGameLogic();

    when(mock.getCurrentImage()).thenReturn('assets/images/revista.png');
    when(mock.getCorrectBinForCurrentItem()).thenReturn('azul');
    when(mock.getCurrentProgress()).thenReturn(1);
    when(mock.getTotalItems()).thenReturn(5);
    when(mock.isGameFinished()).thenReturn(false);
    when(mock.correctAnswers).thenReturn(1);
    when(mock.lastResultText).thenReturn('azul');
    when(mock.lastResultBin).thenReturn('azul');
    when(mock.lastResultCorrect).thenReturn(true);
    when(mock.trashItems).thenReturn([
      {'image': 'assets/images/revista.png', 'correctBin': 'azul'}
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: EasyTrashSortingGame(gameLogicOverride: mock),
      ),
    );

    // Verifica se a mensagem de acerto aparece
    expect(find.text('CERTO! ERA AZUL'), findsOneWidget);
  });
}