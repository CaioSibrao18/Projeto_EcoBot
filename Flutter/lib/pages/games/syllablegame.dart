import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: SpellingGameSyllables()));
}

class SpellingGameSyllables extends StatefulWidget {
  const SpellingGameSyllables({super.key});

  @override
  _SpellingGameSyllablesState createState() => _SpellingGameSyllablesState();
}

class _SpellingGameSyllablesState extends State<SpellingGameSyllables> {
  final List<Map<String, dynamic>> words = [
    {
      'word': 're-ci-clar',
      'syllables': ['re', 'ci', 'clar'],
    },
    {
      'word': 'e-ne-rgia',
      'syllables': ['e', 'ne', 'rgia'],
    },
    {
      'word': 'sus-ten-tá-vel',
      'syllables': ['sus', 'ten', 'tá', 'vel'],
    },
  ];

  int currentWordIndex = 0;
  int correctAnswers = 0;
  List<String> selectedSyllables = [];
  List<String> availableSyllables = [];
  Color boxColor = Colors.grey[300]!;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      selectedSyllables.clear();
      availableSyllables = List.from(words[currentWordIndex]['syllables']);
      availableSyllables.shuffle();
      boxColor = Colors.grey[300]!;
    });
  }

  void checkAnswer() {
    String formedWord = selectedSyllables.join('-');
    if (formedWord == words[currentWordIndex]['word']) {
      setState(() {
        boxColor = Colors.green;
        correctAnswers++;
      });
      Future.delayed(Duration(seconds: 1), () {
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
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          currentWordIndex++;
          if (currentWordIndex < words.length) {
            resetGame();
          } else {
            showResult();
          }
        });
      });
    }
  }

  void showResult() {
    double percentage = (correctAnswers / words.length) * 100;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Resultado'),
            content: Text(
              'Você acertou ${percentage.toStringAsFixed(1)}% das palavras!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    currentWordIndex = 0;
                    correctAnswers = 0;
                    resetGame();
                  });
                  Navigator.pop(context);
                },
                child: Text('Tentar Novamente'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Soletrar por Sílabas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Monte a palavra:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children:
                  availableSyllables
                      .map<Widget>(
                        (syllable) => Material(
                          child: Draggable<String>(
                            data: syllable,
                            feedback: Material(
                              child: Chip(label: Text(syllable)),
                            ),
                            childWhenDragging: SizedBox.shrink(),
                            child: Chip(label: Text(syllable)),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 20),
            DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: EdgeInsets.all(10),
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    selectedSyllables.join('-'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              },
              onAcceptWithDetails: (data) {
                setState(() {
                  selectedSyllables.add(data as String);
                  availableSyllables.remove(data);
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: checkAnswer, child: Text('Confirmar')),
          ],
        ),
      ),
    );
  }
}
