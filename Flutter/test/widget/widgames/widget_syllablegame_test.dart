import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecoquest/pages/games/syllablegame.dart';
import 'package:ecoquest/pages/games/syllablegame_logic.dart';

@GenerateMocks([http.Client])
import 'widget_spelling_game_syllables_test.mocks.dart';

class MockGameLogic extends Mock implements SyllableGameLogic {}

void main() {
  late MockGameLogic mockLogic;
  late MockClient mockHttpClient;
  final sampleWords = [
    {'word': 're-ci-clar', 'syllables': ['re', 'ci', 'clar']},
    {'word': 'a-gua', 'syllables': ['a', 'gua']},
  ];

  setUp(() {
    mockLogic = MockGameLogic();
    mockHttpClient = MockClient();

    // Configurações padrão
    when(mockLogic.availableSyllables).thenReturn(['re', 'ci', 'clar']);
    when(mockLogic.selectedSyllables).thenReturn([]);
    when(mockLogic.currentWordIndex).thenReturn(0);
    when(mockLogic.isGameComplete).thenReturn(false);
  });

  testWidgets('Teste de renderização inicial', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SpellingGameSyllables(
          words: sampleWords,
          gameLogic: mockLogic,
          client: mockHttpClient,
        ),
      ),
    );

    expect(find.text('Arraste as sílabas'), findsOneWidget);
    expect(find.byType(Draggable), findsNWidgets(3));
  });

  testWidgets('Teste de resposta correta', (tester) async {
    when(mockLogic.checkAnswer()).thenReturn(true);
    
    await tester.pumpWidget(
      MaterialApp(
        home: SpellingGameSyllables(
          words: sampleWords,
          gameLogic: mockLogic,
          client: mockHttpClient,
        ),
      ),
    );

    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    verify(mockLogic.checkAnswer()).called(1);
    expect(find.byType(SnackBar), findsNothing); // Adapte conforme sua UI
  });
}