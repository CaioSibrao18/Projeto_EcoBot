// spelling_game_syllables_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ecoquest/pages/games/syllablegame.dart';
import 'package:ecoquest/pages/games/syllablegame_logic.dart';
import 'dart:convert';

// Mock manual para http.Client
class MockHttpClient {
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    return http.Response(json.encode({'success': true}), 200);
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response(json.encode({
      'analysis': {
        'feedback': [
          "Feedback mockado 1",
          "Feedback mockado 2"
        ],
        'current_period': {
          'best_score': 8,
          'consistency': 1.2,
          'count': 1,
          'accuracy_avg': 90.0
        },
        'previous_period': {
          'best_score': 6,
          'consistency': 1.5,
          'count': 1,
          'speed_avg': 3.2
        },
        'trends': {
          'accuracy': 0.2,
          'consistency': -0.3,
          'speed': 0.1
        }
      }
    }), 200);
  }
}

// Mock manual para SyllableGameLogic
class MockGameLogic extends SyllableGameLogic {
  bool mockCheckAnswerResult = true;
  
  MockGameLogic({required List<Map<String, dynamic>> words}) : super(words: words);

  @override
  bool checkAnswer() => mockCheckAnswerResult;

  @override
  void goToNextWord() {
    if (!isGameComplete) {
      currentWordIndex++;
    }
  }
}

void main() {
  late MockGameLogic mockGameLogic;
  final mockWords = [
    {'word': 'teste', 'syllables': ['tes', 'te']},
    {'word': 'outra', 'syllables': ['ou', 'tra']}
  ];

  setUp(() {
    mockGameLogic = MockGameLogic(words: mockWords);
  });

  testWidgets('Deve renderizar a tela inicial corretamente', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SpellingGameSyllables(),
      ),
    );

    expect(find.text('Arraste as sílabas para formar a palavra correta'), findsOneWidget);
    expect(find.byType(Draggable), findsWidgets);
    expect(find.byType(DragTarget), findsOneWidget);
  });

  testWidgets('Deve permitir arrastar sílabas para a área de montagem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SpellingGameSyllables(),
      ),
    );

    // Encontra a primeira sílaba disponível
    final syllableWidget = find.descendant(
      of: find.byType(Wrap),
      matching: find.byType(Draggable<String>).first,
    );
    
    // Arrasta a sílaba para a área de montagem
    await tester.drag(syllableWidget, const Offset(0, 100));
    await tester.pump();

    // Verifica se a sílaba foi adicionada
    expect(find.byType(DragTarget), findsOneWidget);
  });

  testWidgets('Deve mostrar diálogo ao completar o jogo', (tester) async {
    // Configura o mock para apenas 1 palavra para simplificar o teste
    final singleWordLogic = MockGameLogic(words: [
      {'word': 'teste', 'syllables': ['tes', 'te']}
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SpellingGameSyllables(),
      ),
    );

    // Acessa o state e substitui a lógica pelo mock
    final widgetState = tester.state(
      find.byType(SpellingGameSyllables)
    ) as dynamic; // Usamos dynamic para evitar problemas com a classe privada
    
    widgetState.gameLogic = singleWordLogic;

    // Simula completar a palavra
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Verifica se o diálogo aparece
    expect(find.text('JOGO CONCLUÍDO!'), findsOneWidget);
  });

  testWidgets('Deve reiniciar o jogo corretamente', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SpellingGameSyllables(),
      ),
    );

    // Simula completar o jogo
    final widgetState = tester.state(
      find.byType(SpellingGameSyllables)
    ) as dynamic;
    
    widgetState.gameLogic = mockGameLogic;
    widgetState._showResult(); // Acessando método privado via dynamic
    
    await tester.pumpAndSettle();

    // Clica no botão Reiniciar
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();

    // Verifica se a tela principal está visível novamente
    expect(find.text('Arraste as sílabas para formar a palavra correta'), findsOneWidget);
  });
}