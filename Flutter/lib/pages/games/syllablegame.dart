import 'package:flutter/material.dart';

class SpellingGameSyllables extends StatefulWidget {
  const SpellingGameSyllables({super.key});

  @override
  _SpellingGameSyllablesState createState() => _SpellingGameSyllablesState();
}

class _SpellingGameSyllablesState extends State<SpellingGameSyllables> {
  final List<Map<String, dynamic>> words = [
    {'word': 'ga-to', 'syllables': ['ga', 'to', 'la']},
    {'word': 'ca-sa', 'syllables': ['ca', 'sa', 'po']},
    {'word': 'bo-la', 'syllables': ['bo', 'la', 'ra']},
  ];

  int currentWordIndex = 0;
  int correctAnswers = 0;

  List<String> selectedSyllables = [];
  late List<String> availableSyllables;
  Color boxColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    availableSyllables = List.from(words[currentWordIndex]['syllables']);
    availableSyllables.shuffle();
  }

  void checkAnswer() {
    String formedWord =
        selectedSyllables.join('-').replaceAll(RegExp(r'\s+'), '').toLowerCase();
    String correctWord = words[currentWordIndex]['word']
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();

    if (formedWord == correctWord) {
      setState(() {
        boxColor = Colors.green;
        correctAnswers++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (currentWordIndex < words.length - 1) {
          setState(() {
            currentWordIndex++;
          });
          resetGame();
        } else {
          showResult();
        }
      });
    } else {
      setState(() {
        boxColor = Colors.red;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (currentWordIndex < words.length - 1) {
          setState(() {
            currentWordIndex++;
          });
          resetGame();
        } else {
          showResult();
        }
      });
    }
  }

  void resetGame() {
    setState(() {
      selectedSyllables.clear();
      availableSyllables = List.from(words[currentWordIndex]['syllables']);
      availableSyllables.shuffle();
      boxColor = Colors.grey.shade300;
    });
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fim de Jogo'),
        content: Text('Você acertou $correctAnswers de ${words.length} palavras!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentWordIndex = 0;
                correctAnswers = 0;
              });
              resetGame();
            },
            child: const Text('Jogar Novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jogo de Soletrar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
        centerTitle: true,
      ),
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Arraste as sílabas para formar a palavra:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableSyllables.map((syllable) {
                  return Draggable<String>(
                    data: syllable,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildSyllableChip(syllable, feedback: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildSyllableChip(syllable),
                    ),
                    child: _buildSyllableChip(syllable),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Sílabas selecionadas como chips clicáveis
              Wrap(
                spacing: 8,
                children: selectedSyllables.map((syllable) {
                  return InputChip(
                    label: Text(syllable),
                    onDeleted: () {
                      setState(() {
                        selectedSyllables.remove(syllable);
                        availableSyllables.add(syllable);
                        availableSyllables.shuffle();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 100,
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.teal.shade800, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      selectedSyllables.join('-'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  );
                },
                onAccept: (data) {
                  if (!selectedSyllables.contains(data)) {
                    setState(() {
                      selectedSyllables.add(data);
                      availableSyllables.remove(data);
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: checkAnswer,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyllableChip(String syllable, {bool feedback = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: feedback ? Colors.teal.shade400 : Colors.teal.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade400, width: 1.5),
      ),
      child: Text(
        syllable,
        style: TextStyle(
          fontSize: 18,
          color: Colors.teal.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
