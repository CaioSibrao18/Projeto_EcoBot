import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/quizeasy_logic.dart';

void main() {
  // Dados de teste
  final testQuestions = [
    {
      "question": "Pergunta 1",
      "options": ["A", "B", "C"],
      "correctIndex": 0,
    },
    {
      "question": "Pergunta 2",
      "options": ["X", "Y", "Z"],
      "correctIndex": 1,
    },
    {
      "question": "Pergunta 3",
      "options": ["Sim", "Não"],
      "correctIndex": 0,
    },
  ];

  // Teste 1: Verifica a inicialização correta
  test('Inicialização correta do QuizEasyLogic', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    expect(logic.currentQuestionIndex, 0);
    expect(logic.selectedOption, isNull);
    expect(logic.correctAnswers, 0);
    expect(logic.getCurrentQuestion(), testQuestions[0]);
  });

  // Teste 2: Verifica resposta correta
  test('Resposta correta incrementa a pontuação', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    logic.checkAnswer(0); // Resposta correta para primeira pergunta
    expect(logic.correctAnswers, 1);
    expect(logic.selectedOption, 0);
  });

  // Teste 3: Verifica resposta incorreta
  test('Resposta incorreta não incrementa a pontuação', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    logic.checkAnswer(1); // Resposta incorreta para primeira pergunta
    expect(logic.correctAnswers, 0);
    expect(logic.selectedOption, 1);
  });

  // Teste 4: Avança para próxima pergunta
  test('Próxima pergunta é carregada corretamente', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    logic.checkAnswer(0);
    logic.nextQuestion();
    
    expect(logic.currentQuestionIndex, 1);
    expect(logic.selectedOption, isNull);
    expect(logic.getCurrentQuestion(), testQuestions[1]);
  });

  // Teste 5: Verifica fim do jogo
  test('Fim do jogo é detectado corretamente', () {
    final logic = QuizEasyLogic(questions: testQuestions.sublist(0, 2)); // Apenas 2 perguntas
    
    // Responde primeira pergunta
    logic.checkAnswer(0);
    logic.nextQuestion();
    
    // Responde segunda pergunta
    logic.checkAnswer(1);
    
    expect(logic.isGameOver(), isTrue);
  });

  // Teste 6: Reinicia o jogo corretamente
  test('Reinicialização do jogo', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    // Simula algumas jogadas
    logic.checkAnswer(0);
    logic.nextQuestion();
    logic.checkAnswer(1);
    
    // Reinicia o jogo
    logic.resetGame();
    
    expect(logic.currentQuestionIndex, 0);
    expect(logic.correctAnswers, 0);
    expect(logic.selectedOption, isNull);
  });

  // Teste 7: Verifica resultados do jogo
  test('Resultados do jogo são calculados corretamente', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    // Simula respostas
    logic.checkAnswer(0); // Correta
    logic.nextQuestion();
    logic.checkAnswer(2); // Incorreta
    logic.nextQuestion();
    logic.checkAnswer(0); // Correta
    
    final results = logic.getGameResults();
    
    expect(results['correctAnswers'], 2);
    expect(results['totalQuestions'], 3);
    expect(results['timeInSeconds'], greaterThanOrEqualTo(0));
  });

  // Teste 8: Verifica se resposta está correta
  test('Verificação de resposta correta', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    expect(logic.isAnswerCorrect(0), isTrue); // Primeira pergunta, opção 0 é correta
    expect(logic.isAnswerCorrect(1), isFalse);
  });

  // Teste 9: Tempo decorrido
  test('Tempo decorrido é medido corretamente', () {
    final logic = QuizEasyLogic(questions: testQuestions);
    
    // Espera um pouco para medir o tempo
    Future.delayed(const Duration(milliseconds: 100), () {
      final time = logic.getElapsedTimeInSeconds();
      expect(time, greaterThan(0));
    });
  });

  // Teste 10: Não avança após última pergunta
  test('Não avança além da última pergunta', () {
    final logic = QuizEasyLogic(questions: testQuestions.sublist(0, 1)); // Apenas 1 pergunta
    
    logic.checkAnswer(0);
    logic.nextQuestion();
    
    expect(logic.currentQuestionIndex, 0); // Deve permanecer na primeira (e única) pergunta
  });
}