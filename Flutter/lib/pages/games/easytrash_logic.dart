// easytrash_logic.dart
class EasyTrashGameLogic {
  final List<Map<String, dynamic>> trashItems;
  int currentItemIndex;
  int correctAnswers;
  String? lastResultText;
  String? lastResultBin;
  bool? lastResultCorrect;

  EasyTrashGameLogic({
    required this.trashItems,
    this.currentItemIndex = 0,
    this.correctAnswers = 0,
    this.lastResultText,
    this.lastResultBin,
    this.lastResultCorrect,
  });

  // Lógica para verificar a resposta
  void checkAnswer(String selectedBin) {
    String correctBin = trashItems[currentItemIndex]['correctBin'];
    bool isCorrect = selectedBin == correctBin;

    lastResultText = correctBin;
    lastResultBin = selectedBin;
    lastResultCorrect = isCorrect;

    if (isCorrect) correctAnswers++;
  }

  // Avança para o próximo item
  void nextItem() {
    if (currentItemIndex < trashItems.length - 1) {
      currentItemIndex++;
      lastResultText = null;
      lastResultCorrect = null;
      lastResultBin = null;
    }
  }

  // Verifica se o jogo terminou
  bool isGameFinished() {
    return currentItemIndex >= trashItems.length - 1;
  }

  // Reinicia o jogo
  void resetGame() {
    currentItemIndex = 0;
    correctAnswers = 0;
    lastResultText = null;
    lastResultCorrect = null;
    lastResultBin = null;
  }

  // Getters para dados do jogo
  String getCurrentImage() {
    return trashItems[currentItemIndex]['image'];
  }

  String getCorrectBinForCurrentItem() {
    return trashItems[currentItemIndex]['correctBin'];
  }

  int getTotalItems() {
    return trashItems.length;
  }

  int getCurrentProgress() {
    return currentItemIndex + 1;
  }
}