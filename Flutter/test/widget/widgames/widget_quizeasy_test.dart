import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecoquest/pages/games/quizeasy_logic.dart'; // AJUSTE O CAMINHO
import 'package:ecoquest/pages/games/quizeasy.dart'; // AJUSTE O CAMINHO

// --- MOCKS MANUAIS ---
// Mock para QuizEasyLogic
class MockQuizEasyLogic extends Mock implements QuizEasyLogic {
  @override
  List<Map<String, dynamic>> get questions => super.noSuchMethod(
        Invocation.getter(#questions),
        returnValue: <Map<String, dynamic>>[],
      ) as List<Map<String, dynamic>>;

  @override
  int get currentQuestionIndex => super.noSuchMethod(
        Invocation.getter(#currentQuestionIndex),
        returnValue: 0,
      ) as int;

  @override
  set currentQuestionIndex(int? _currentQuestionIndex) => super.noSuchMethod(
        Invocation.setter(#currentQuestionIndex, _currentQuestionIndex),
        returnValueForMissingStub: null,
      );

  @override
  int? get selectedOption => super.noSuchMethod(
        Invocation.getter(#selectedOption),
        returnValue: null,
      ) as int?;

  @override
  set selectedOption(int? _selectedOption) => super.noSuchMethod(
        Invocation.setter(#selectedOption, _selectedOption),
        returnValueForMissingStub: null,
      );

  @override
  int get correctAnswers => super.noSuchMethod(
        Invocation.getter(#correctAnswers),
        returnValue: 0,
      ) as int;

  @override
  set correctAnswers(int? _correctAnswers) => super.noSuchMethod(
        Invocation.setter(#correctAnswers, _correctAnswers),
        returnValueForMissingStub: null,
      );

  @override
  void checkAnswer(int? index) => super.noSuchMethod(
        Invocation.method(#checkAnswer, [index]),
        returnValueForMissingStub: null,
      );

  @override
  void nextQuestion() => super.noSuchMethod(
        Invocation.method(#nextQuestion, []),
        returnValueForMissingStub: null,
      );

  @override
  bool isGameOver() => super.noSuchMethod(
        Invocation.method(#isGameOver, []),
        returnValue: false,
      ) as bool;

  @override
  void resetGame() => super.noSuchMethod(
        Invocation.method(#resetGame, []),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, dynamic> getGameResults() => super.noSuchMethod(
        Invocation.method(#getGameResults, []),
        returnValue: <String, dynamic>{'correctAnswers': 0, 'totalQuestions': 1, 'timeInSeconds': 0},
      ) as Map<String, dynamic>;

  @override
  Map<String, dynamic> getCurrentQuestion() => super.noSuchMethod(
        Invocation.method(#getCurrentQuestion, []),
        returnValue: <String, dynamic>{
          'question': 'Qual a cor da lixeira de papel?',
          'options': ['Azul', 'Vermelha', 'Verde'],
          'correctIndex': 0,
        },
      ) as Map<String, dynamic>;

  @override
  bool isAnswerCorrect(int? answerIndex) => super.noSuchMethod(
        Invocation.method(#isAnswerCorrect, [answerIndex]),
        returnValue: false,
      ) as bool;
}

// Mock para http.Client
class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.Response> post(Uri? url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      super.noSuchMethod(Invocation.method(#post, [url], {#headers: headers, #body: body, #encoding: encoding}), returnValue: Future.value(http.Response('{}', 200))) as Future<http.Response>;

  @override
  Future<http.Response> get(Uri? url, {Map<String, String>? headers}) =>
      super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}), returnValue: Future.value(http.Response('{}', 200))) as Future<http.Response>;
}

// Mock para Navigator (para testar navegação de volta)
class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => super.noSuchMethod(
        Invocation.method(#didPush, [route, previousRoute]),
        returnValueForMissingStub: null, // Pode ser null para void methods
      );
}
// --- FIM DOS MOCKS MANUAIS ---

void main() {
  late MockQuizEasyLogic mockGameLogic;
  late MockHttpClient mockHttpClient;
  late MockNavigatorObserver mockNavigatorObserver;

  final List<Map<String, dynamic>> quizQuestions = [
    {"question": "Qual a cor da lixeira de papel?", "options": ["Azul", "Vermelha", "Verde"], "correctIndex": 0},
    {"question": "Qual a cor da lixeira de plástico?", "options": ["Azul", "Vermelha", "Verde"], "correctIndex": 1},
    {"question": "O vidro pode ser reciclado?", "options": ["Sim", "Não", "Somente garrafas"], "correctIndex": 0},
  ];

  setUp(() {
    mockGameLogic = MockQuizEasyLogic();
    mockHttpClient = MockHttpClient();
    mockNavigatorObserver = MockNavigatorObserver();

    // Comportamento padrão para a lógica do jogo
    when(mockGameLogic.questions).thenReturn(quizQuestions);
    when(mockGameLogic.currentQuestionIndex).thenReturn(0);
    when(mockGameLogic.selectedOption).thenReturn(null);
    when(mockGameLogic.correctAnswers).thenReturn(0);
    when(mockGameLogic.isGameOver()).thenReturn(false);
    when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions[0]);
    when(mockGameLogic.getGameResults()).thenReturn({
      'correctAnswers': 0,
      'totalQuestions': quizQuestions.length,
      'timeInSeconds': 0,
    });

    // Comportamento padrão para as chamadas HTTP
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

  group('QuizScreenEasy Tests', () {
    testWidgets('Renders initial elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreenEasy(),
        ),
      );

      // Verify initial elements
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Logo
      expect(find.text('Qual a cor da lixeira de papel?'), findsOneWidget); // First question
      expect(find.text('Azul'), findsOneWidget);
      expect(find.text('Vermelha'), findsOneWidget);
      expect(find.text('Verde'), findsOneWidget);
      expect(find.text('Pergunta 1 de ${quizQuestions.length}'), findsOneWidget);
    });

    testWidgets('Selects an option and updates UI for correct answer', (WidgetTester tester) async {
      // Configura o mock para a primeira pergunta (correta: Azul - index 0)
      when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions[0]);
      when(mockGameLogic.isAnswerCorrect(0)).thenReturn(true);

      // Simula a lógica de resposta e avanço
      when(mockGameLogic.checkAnswer(0)).thenAnswer((_) {
        // Marca a opção selecionada para simular o estado
        when(mockGameLogic.selectedOption).thenReturn(0);
        // Aumenta os acertos
        when(mockGameLogic.correctAnswers).thenReturn(1);
      });

      when(mockGameLogic.nextQuestion()).thenAnswer((_) {
        // Simula o avanço para a próxima pergunta
        when(mockGameLogic.currentQuestionIndex).thenReturn(1);
        when(mockGameLogic.selectedOption).thenReturn(null); // Reseta selectedOption
        when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions[1]);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreenEasy(key: const Key('QuizScreenEasy')), // Adicione uma Key
        ),
      );

      // Tapa na opção correta (Azul)
      await tester.tap(find.text('Azul'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Verifica se a cor mudou para verde (opção selecionada correta)
      final correctOptionFinder = find.widgetWithText(Material, 'Azul');
      final Material material = tester.widget(correctOptionFinder);
      expect(material.color, Colors.green);

      // Aguarda o delay para avançar
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifica se a lógica de checagem e avanço foi chamada
      verify(mockGameLogic.checkAnswer(0)).called(1);
      verify(mockGameLogic.nextQuestion()).called(1);

      // Verifica se a próxima pergunta foi renderizada
      expect(find.text('Qual a cor da lixeira de plástico?'), findsOneWidget);
      expect(find.text('Pergunta 2 de ${quizQuestions.length}'), findsOneWidget);
    });


    testWidgets('Selects an option and updates UI for incorrect answer', (WidgetTester tester) async {
      // Configura o mock para a primeira pergunta (correta: Azul - index 0)
      when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions[0]);
      when(mockGameLogic.isAnswerCorrect(0)).thenReturn(true); // A correta é Azul (index 0)

      // Simula o cenário de resposta incorreta
      when(mockGameLogic.checkAnswer(1)).thenAnswer((_) { // Tenta responder 'Vermelha' (index 1)
        when(mockGameLogic.selectedOption).thenReturn(1); // Marca a opção selecionada como 1
        when(mockGameLogic.correctAnswers).thenReturn(0); // Não aumenta acertos
      });

      when(mockGameLogic.nextQuestion()).thenAnswer((_) {
        when(mockGameLogic.currentQuestionIndex).thenReturn(1);
        when(mockGameLogic.selectedOption).thenReturn(null);
        when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions[1]);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreenEasy(key: const Key('QuizScreenEasy')),
        ),
      );

      // Tapa na opção incorreta (Vermelha)
      await tester.tap(find.text('Vermelha'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verifica se a opção tapada ficou vermelha
      final incorrectOptionFinder = find.widgetWithText(Material, 'Vermelha');
      final Material incorrectMaterial = tester.widget(incorrectOptionFinder);
      expect(incorrectMaterial.color, Colors.red);

      // Verifica se a opção correta foi destacada (verde claro)
      final correctOptionFinder = find.widgetWithText(Material, 'Azul');
      final Material correctMaterial = tester.widget(correctOptionFinder);
      expect(correctMaterial.color, Colors.green.withOpacity(0.3));

      // Verifica se a mensagem de resposta correta é exibida
      expect(find.text('Resposta correta: Azul'), findsOneWidget);

      // Aguarda o delay para avançar
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifica se a lógica de checagem e avanço foi chamada
      verify(mockGameLogic.checkAnswer(1)).called(1);
      verify(mockGameLogic.nextQuestion()).called(1);

      // Verifica se a próxima pergunta foi renderizada
      expect(find.text('Qual a cor da lixeira de plástico?'), findsOneWidget);
      expect(find.text('Pergunta 2 de ${quizQuestions.length}'), findsOneWidget);
      expect(find.text('Resposta correta: Azul'), findsNothing); // A mensagem deve sumir
    });

    testWidgets('Game finishes and shows result dialog', (WidgetTester tester) async {
      // Simula que é a última pergunta
      when(mockGameLogic.currentQuestionIndex).thenReturn(quizQuestions.length - 1); // CORREÇÃO AQUI
      when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions.last);
      when(mockGameLogic.isAnswerCorrect(0)).thenReturn(true); // Simula uma resposta correta para a última

      // Simula o cenário de jogo finalizado
      when(mockGameLogic.checkAnswer(0)).thenAnswer((_) {
        when(mockGameLogic.selectedOption).thenReturn(0);
        when(mockGameLogic.correctAnswers).thenReturn(quizQuestions.length); // Todas corretas
      });
      when(mockGameLogic.isGameOver()).thenReturn(true); // Diz que o jogo terminou

      // Mocka os resultados do jogo
      when(mockGameLogic.getGameResults()).thenReturn({
        'correctAnswers': quizQuestions.length,
        'totalQuestions': quizQuestions.length,
        'timeInSeconds': 30, // Exemplo de tempo
      });

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreenEasy(key: const Key('QuizScreenEasy')),
        ),
      );

      // Tapa na opção para finalizar o jogo (simulando a última resposta)
      await tester.tap(find.text(quizQuestions.last['options'][0])); // Tapa na primeira opção da última pergunta
      await tester.pumpAndSettle(); // Aguarda o setState e o showDialog

      // Verifica se o diálogo de resultados apareceu
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Resultado - Nível Fácil'), findsOneWidget);
      expect(find.text('QUIZ CONCLUÍDO!'), findsOneWidget);
      expect(find.text('${quizQuestions.length}/${quizQuestions.length} corretas'), findsOneWidget);
      expect(find.text('Tempo: 30 segundos'), findsOneWidget);
      expect(find.text('Feedback do Mock'), findsOneWidget); // Do mock do HTTP
      expect(find.text('Continue praticando!'), findsOneWidget); // Do mock do HTTP

      // Verifica se as chamadas HTTP foram feitas
      verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      verify(mockHttpClient.get(any)).called(1);
    });

    testWidgets('Restart button in dialog resets game state', (WidgetTester tester) async {
      // Simula que o jogo terminou para mostrar o diálogo
      when(mockGameLogic.currentQuestionIndex).thenReturn(quizQuestions.length - 1); // CORREÇÃO AQUI
      when(mockGameLogic.isGameOver()).thenReturn(true);
      when(mockGameLogic.getCurrentQuestion()).thenReturn(quizQuestions.last);
      when(mockGameLogic.getGameResults()).thenReturn({
        'correctAnswers': quizQuestions.length,
        'totalQuestions': quizQuestions.length,
        'timeInSeconds': 30,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreenEasy(key: const Key('QuizScreenEasy')),
        ),
      );

      // Finaliza o jogo para abrir o diálogo
      await tester.tap(find.text(quizQuestions.last['options'][0])); // Responde a última pergunta
      await tester.pumpAndSettle();

      // Verifica se o botão "Reiniciar" está presente e o toca
      expect(find.text('Reiniciar'), findsOneWidget);
      await tester.tap(find.text('Reiniciar'));
      await tester.pumpAndSettle(); // Aguarda o pop do diálogo e o setState de reset

      // Verifica se a lógica de reset foi chamada
      verify(mockGameLogic.resetGame()).called(1);

      // Verifica se o diálogo sumiu
      expect(find.byType(Dialog), findsNothing);

      // Verifica se a tela voltou para o estado inicial (primeira pergunta)
      expect(find.text('Qual a cor da lixeira de papel?'), findsOneWidget);
      expect(find.text('Pergunta 1 de ${quizQuestions.length}'), findsOneWidget);
    });

    testWidgets('Back button navigates to /menu_games', (WidgetTester tester) async {
      // Define a rota inicial como a tela do quiz
      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreenEasy(),
          navigatorObservers: [mockNavigatorObserver],
          routes: {
            '/menu_games': (context) => const Text('Menu de Jogos'), // Uma tela mock para a rota
          },
        ),
      );

      // Verifica se o botão de voltar está presente
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Toca no botão de voltar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(); // Espera a navegação terminar

      expect(find.text('Menu de Jogos'), findsOneWidget);
      expect(find.byType(QuizScreenEasy), findsNothing);
    });
  });
}