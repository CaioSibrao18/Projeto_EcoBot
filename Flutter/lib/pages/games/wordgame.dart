import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpellingGameLetters extends StatefulWidget {
  const SpellingGameLetters({super.key});

  @override
  _SpellingGameLettersState createState() => _SpellingGameLettersState();
}

class _SpellingGameLettersState extends State<SpellingGameLetters> {
  final List<Map<String, dynamic>> words = [
    {'word': 'reciclar', 'letters': ['r', 'e', 'c', 'i', 'c', 'l', 'a', 'r']},
    {'word': 'ecossistema', 'letters': ['e', 'c', 'o', 's', 's', 'i', 's', 't', 'e', 'm', 'a']},
    {'word': 'compostagem', 'letters': ['c', 'o', 'm', 'p', 'o', 's', 't', 'a', 'g', 'e', 'm']},
    {'word': 'sustentabilidade', 'letters': ['s', 'u', 's', 't', 'e', 'n', 't', 'a', 'b', 'i', 'l', 'i', 'd', 'a', 'd', 'e']},
    {'word': 'biodiversidade', 'letters': ['b', 'i', 'o', 'd', 'i', 'v', 'e', 'r', 's', 'i', 'd', 'a', 'd', 'e']},
    {'word': 'energia', 'letters': ['e', 'n', 'e', 'r', 'g', 'i', 'a']},
    {'word': 'natureza', 'letters': ['n', 'a', 't', 'u', 'r', 'e', 'z', 'a']},
    {'word': 'renovavel', 'letters': ['r', 'e', 'n', 'o', 'v', 'a', 'v', 'e', 'l']},
    {'word': 'preservar', 'letters': ['p', 'r', 'e', 's', 'e', 'r', 'v', 'a', 'r']},
    {'word': 'consciente', 'letters': ['c', 'o', 'n', 's', 'c', 'i', 'e', 'n', 't', 'e']},
  ];

  int currentWordIndex = 0;
  int correctAnswers = 0;
  List<String> selectedLetters = [];
  List<String> availableLetters = [];
  bool showCorrectWord = false;
  String correctWord = '';
  Color boxColor = Colors.grey[200]!;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      selectedLetters.clear();
      availableLetters = List.from(words[currentWordIndex]['letters']);
      availableLetters.shuffle();
      showCorrectWord = false;
      correctWord = words[currentWordIndex]['word'];
      boxColor = Colors.grey[200]!;
    });
  }

  void checkAnswer() {
    String formedWord = selectedLetters.join('');
    String answer = correctWord;

    if (formedWord == answer) {
      setState(() {
        boxColor = Colors.greenAccent;
        correctAnswers++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        goToNextWord();
      });
    } else {
      setState(() {
        boxColor = Colors.redAccent;
        showCorrectWord = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        goToNextWord();
      });
    }
  }

  void goToNextWord() {
    if (currentWordIndex < words.length - 1) {
      setState(() {
        currentWordIndex++;
        resetGame();
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    final percentage = (correctAnswers / words.length) * 100;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resultado'),
        content: Text('Você acertou ${percentage.toStringAsFixed(1)}% das palavras!'),
        actions: [
          TextButton(
            onPressed: () {
              _sendResultToBackend(correctAnswers);
              setState(() {
                currentWordIndex = 0;
                correctAnswers = 0;
                resetGame();
              });
              Navigator.pop(context);
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResultToBackend(int acertos) async {
    final url = Uri.parse('http://localhost:5000/api/saveResult');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario_id': 4,
        'acertos': acertos,
        'tempo_segundos': 0,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    int half = (availableLetters.length / 2).ceil();
    List<String> topRow = availableLetters.take(half).toList();
    List<String> bottomRow = availableLetters.skip(half).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logoEcoQuest.png',
                      height: 240,
                      width: 240,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Arraste as letras para formar a palavra correta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PressStart2P',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLetterRow(topRow),
                    _buildLetterRow(bottomRow),
                    const SizedBox(height: 30),
                    DragTarget<String>(
                      builder: (context, candidateData, rejectedData) => Container(
                        padding: const EdgeInsets.all(16),
                        height: 80,
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2BB462), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          selectedLetters.join(''),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PressStart2P',
                          ),
                        ),
                      ),
                      onAcceptWithDetails: (data) {
                        if (availableLetters.contains(data)) {
                          setState(() {
                            selectedLetters.add(data as String);
                            availableLetters.remove(data);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    if (showCorrectWord)
                      Column(
                        children: [
                          const Text(
                            'Palavra correta:',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'PressStart2P',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            correctWord
                                .split('')
                                .map((l) => l)
                                .join('-'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: 'PressStart2P',
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: checkAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2BB462),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: resetGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Limpar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Palavra ${currentWordIndex + 1} de ${words.length}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontFamily: 'PressStart2P',
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Color(0xFF2BB462)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterRow(List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Draggable<String>(
          data: letter,
          feedback: _letterTile(letter, dragging: true),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: _letterTile(letter),
          ),
          child: _letterTile(letter),
        ),
      )).toList(),
    );
  }

  Widget _letterTile(String letter, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFF2BB462) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2BB462), width: 2),
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontFamily: 'PressStart2P',
          color: dragging ? Colors.white : const Color(0xFF2BB462),
          fontSize: 12,
        ),
      ),
    );
  }
}