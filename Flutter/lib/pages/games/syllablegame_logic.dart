class SyllableGameLogic {
  final List<Map<String, dynamic>> words;
  int currentWordIndex;
  int correctAnswers;
  List<String> availableSyllables;
  List<String> selectedSyllables;
  String? incorrectWord;
  List<int> wordTimes = [];

  SyllableGameLogic({
    required this.words,
    this.currentWordIndex = 0,
    this.correctAnswers = 0,
    List<String>? availableSyllables,
    List<String>? selectedSyllables,
    this.incorrectWord,
  })  : availableSyllables = availableSyllables ?? [],
        selectedSyllables = selectedSyllables ?? [];

  void resetGame() {
    selectedSyllables.clear();
    availableSyllables = List.from(words[currentWordIndex]['syllables']);
    availableSyllables.shuffle();
    incorrectWord = null;
  }

  void addSyllable(String syllable) {
    selectedSyllables.add(syllable);
    availableSyllables.remove(syllable);
  }

  bool checkAnswer() {
    final formedWord = selectedSyllables.join('-');
    final correctWord = words[currentWordIndex]['word'];

    if (formedWord == correctWord) {
      correctAnswers++;
      return true;
    } else {
      incorrectWord = correctWord;
      return false;
    }
  }

  void goToNextWord() {
    if (currentWordIndex < words.length - 1) {
      currentWordIndex++;
      resetGame();
    }
  }

  bool get isGameComplete => currentWordIndex >= words.length - 1;

  double calculateAverageWordTime() {
    if (wordTimes.isEmpty) return 0;
    return wordTimes.reduce((a, b) => a + b) / wordTimes.length;
  }
}