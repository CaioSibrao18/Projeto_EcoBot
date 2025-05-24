class QuizEasyLogic {
  final List<Map<String, dynamic>> questions;
  int currentQuestionIndex;
  int? selectedOption;
  int correctAnswers;
  final Stopwatch _stopwatch;

  QuizEasyLogic({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.selectedOption,
    this.correctAnswers = 0,
    Stopwatch? stopwatch,
  }) : _stopwatch = stopwatch ?? Stopwatch() {
    _stopwatch.start();
  }

  // Lógica para verificar a resposta
  void checkAnswer(int index) {
    selectedOption = index;
    bool isCorrect = index == questions[currentQuestionIndex]['correctIndex'];
    if (isCorrect) {
      correctAnswers++;
    }
  }

  // Avança para a próxima pergunta
  void nextQuestion() {
    selectedOption = null;
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    }
  }

  // Verifica se o jogo terminou
  bool isGameOver() {
    return currentQuestionIndex >= questions.length - 1 && selectedOption != null;
  }

  // Retorna o tempo decorrido em segundos
  int getElapsedTimeInSeconds() {
    _stopwatch.stop();
    return _stopwatch.elapsed.inSeconds;
  }

  // Reinicia o jogo
  void resetGame() {
    currentQuestionIndex = 0;
    correctAnswers = 0;
    selectedOption = null;
    _stopwatch.reset();
    _stopwatch.start();
  }

  // Retorna os resultados do jogo
  Map<String, dynamic> getGameResults() {
    return {
      'correctAnswers': correctAnswers,
      'totalQuestions': questions.length,
      'timeInSeconds': getElapsedTimeInSeconds(),
    };
  }

  // Retorna a pergunta atual
  Map<String, dynamic> getCurrentQuestion() {
    return questions[currentQuestionIndex];
  }

  // Verifica se uma resposta está correta
  bool isAnswerCorrect(int answerIndex) {
    return answerIndex == questions[currentQuestionIndex]['correctIndex'];
  }
}