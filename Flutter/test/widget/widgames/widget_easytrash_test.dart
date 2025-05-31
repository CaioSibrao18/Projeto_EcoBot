import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ecoquest/pages/games/easytrash_logic.dart';
import 'package:ecoquest/pages/games/easytrash.dart';

// --- MOCKS MANUAIS ---
class MockEasyTrashGameLogic extends Mock implements EasyTrashGameLogic {
  @override
  List<Map<String, dynamic>> get trashItems => super.noSuchMethod(Invocation.getter(#trashItems), returnValue: <Map<String, dynamic>>[]) as List<Map<String, dynamic>>;
  @override
  int get currentItemIndex => super.noSuchMethod(Invocation.getter(#currentItemIndex), returnValue: 0) as int;
  @override
  int get correctAnswers => super.noSuchMethod(Invocation.getter(#correctAnswers), returnValue: 0) as int;
  @override
  set currentItemIndex(int? _currentItemIndex) => super.noSuchMethod(Invocation.setter(#currentItemIndex, _currentItemIndex), returnValueForMissingStub: null);
  @override
  set correctAnswers(int? _correctAnswers) => super.noSuchMethod(Invocation.setter(#correctAnswers, _correctAnswers), returnValueForMissingStub: null);
  @override
  set lastResultText(String? _lastResultText) => super.noSuchMethod(Invocation.setter(#lastResultText, _lastResultText), returnValueForMissingStub: null);
  @override
  set lastResultBin(String? _lastResultBin) => super.noSuchMethod(Invocation.setter(#lastResultBin, _lastResultBin), returnValueForMissingStub: null);
  @override
  set lastResultCorrect(bool? _lastResultCorrect) => super.noSuchMethod(Invocation.setter(#lastResultCorrect, _lastResultCorrect), returnValueForMissingStub: null);
  @override
  void checkAnswer(String? selectedBin) => super.noSuchMethod(Invocation.method(#checkAnswer, [selectedBin]), returnValueForMissingStub: null);
  @override
  void nextItem() => super.noSuchMethod(Invocation.method(#nextItem, []), returnValueForMissingStub: null);
  @override
  bool isGameFinished() => super.noSuchMethod(Invocation.method(#isGameFinished, []), returnValue: false) as bool;
  @override
  void resetGame() => super.noSuchMethod(Invocation.method(#resetGame, []), returnValueForMissingStub: null);
  @override
  String getCurrentImage() => super.noSuchMethod(Invocation.method(#getCurrentImage, []), returnValue: '') as String;
  @override
  String getCorrectBinForCurrentItem() => super.noSuchMethod(Invocation.method(#getCorrectBinForCurrentItem, []), returnValue: '') as String;
  @override
  int getTotalItems() => super.noSuchMethod(Invocation.method(#getTotalItems, []), returnValue: 0) as int;
  @override
  int getCurrentProgress() => super.noSuchMethod(Invocation.method(#getCurrentProgress, []), returnValue: 0) as int;
}

class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.Response> post(Uri? url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      super.noSuchMethod(Invocation.method(#post, [url], {#headers: headers, #body: body, #encoding: encoding}), returnValue: Future.value(http.Response('{}', 200))) as Future<http.Response>;
  @override
  Future<http.Response> get(Uri? url, {Map<String, String>? headers}) =>
      super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}), returnValue: Future.value(http.Response('{}', 200))) as Future<http.Response>;
}
// --- FIM DOS MOCKS MANUAIS ---

void main() {
  late MockEasyTrashGameLogic mockGameLogic;
  late MockHttpClient mockHttpClient;

  final List<Map<String, dynamic>> mockTrashItems = [
    {'image': 'assets/images/revista.png', 'correctBin': 'azul'},
    {'image': 'assets/images/caixadeleite.png', 'correctBin': 'azul'},
    {'image': 'assets/images/sacola.png', 'correctBin': 'vermelha'},
  ];

  setUp(() {
    mockGameLogic = MockEasyTrashGameLogic();
    mockHttpClient = MockHttpClient();

    when(mockGameLogic.trashItems).thenReturn(mockTrashItems);
    when(mockGameLogic.currentItemIndex).thenReturn(0);
    when(mockGameLogic.correctAnswers).thenReturn(0);
    when(mockGameLogic.lastResultText).thenReturn(null);
    when(mockGameLogic.lastResultCorrect).thenReturn(null);
    when(mockGameLogic.lastResultBin).thenReturn(null);
    when(mockGameLogic.getCurrentImage()).thenReturn(mockTrashItems[0]['image']);
    when(mockGameLogic.getCorrectBinForCurrentItem()).thenReturn(mockTrashItems[0]['correctBin']);
    when(mockGameLogic.getCurrentProgress()).thenReturn(1);
    when(mockGameLogic.getTotalItems()).thenReturn(mockTrashItems.length);
    when(mockGameLogic.isGameFinished()).thenReturn(false);

    when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 200));
    when(mockHttpClient.get(any))
        .thenAnswer((_) async => http.Response(
            json.encode({
              'analysis': {
                'feedback': ['Feedback do Mock', 'Continue praticando!'],
                'current_period': {'accuracy_avg': 85.0, 'best_score': 120}
              }
            }),
            200));
  });

  testWidgets('EasyTrashSortingGame renders initial elements correctly', (WidgetTester tester) async {
    // Testa a renderização inicial do widget
    await tester.pumpWidget(
      MaterialApp(
        home: EasyTrashSortingGame(gameLogicOverride: mockGameLogic),
      ),
    );
    expect(find.text('ARRASTE PARA A LIXEIRA CERTA'), findsOneWidget);
    expect(find.image(AssetImage(mockTrashItems[0]['image'])), findsOneWidget);
    expect(find.text('1 / ${mockTrashItems.length}'), findsOneWidget);
  });

  testWidgets('Back button navigates back', (WidgetTester tester) async {
    // Testa se o botão de voltar navega para a tela anterior
    await tester.pumpWidget(
      MaterialApp(
        home: EasyTrashSortingGame(gameLogicOverride: mockGameLogic),
      ),
    );
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(EasyTrashSortingGame), findsNothing);
  });
}