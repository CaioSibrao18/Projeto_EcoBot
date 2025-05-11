import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpellingGameSyllables extends StatefulWidget {
  const SpellingGameSyllables({super.key});

  @override
  _SpellingGameSyllablesState createState() => _SpellingGameSyllablesState();
}

class _SpellingGameSyllablesState extends State<SpellingGameSyllables> {
  final List<Map<String, dynamic>> words = [
    {'word': 're-ci-clar', 'syllables': ['re', 'ci', 'clar']},
    {'word': 'e-ne-rgia', 'syllables': ['e', 'ne', 'rgia']},
    {'word': 'sus-ten-tá-vel', 'syllables': ['sus', 'ten', 'tá', 'vel']},
    {'word': 'a-ma-zô-nia', 'syllables': ['a', 'ma', 'zô', 'nia']},
    {'word': 'a-gua', 'syllables': ['a', 'gua']},
    {'word': 'na-tu-re-za', 'syllables': ['na', 'tu', 're', 'za']},
    {'word': 'po-lu-i-ção', 'syllables': ['po', 'lu', 'i', 'ção']},
    {'word': 're-u-ti-li-zar', 'syllables': ['re', 'u', 'ti', 'li', 'zar']},
    {'word': 'com-pos-ta-gem', 'syllables': ['com', 'pos', 'ta', 'gem']},
    {'word': 'bio-de-gra-dá-vel', 'syllables': ['bio', 'de', 'gra', 'dá', 'vel']},
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

  @override
  void dispose() {
    selectedSyllables.clear();
    availableSyllables.clear();
    super.dispose();
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
    String formedWord = selectedSyllables.join('-').trim();
    String correctWord = words[currentWordIndex]['word'].trim();

    if (formedWord == correctWord) {
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

  void showResult() {
    double percentage = (correctAnswers / words.length) * 100;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _sendResultToBackend(percentage);
            },
            child: Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResultToBackend(double percentage) async {
    final url = Uri.parse('http://localhost:5000/saveResult');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correctAnswers': correctAnswers,
        'totalQuestions': words.length,
        'percentage': percentage,
      }),
    );

    if (response.statusCode == 200) {
      print('Resultado enviado com sucesso!');
    } else {
      print('Falha ao enviar resultado: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Soletrar por Sílabas')),
      body: Center(
        child: SingleChildScrollView(
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
                children: availableSyllables.map<Widget>((syllable) {
                  return Draggable<String>(
                    data: syllable,
                    feedback: Material(child: Chip(label: Text(syllable))),
                    childWhenDragging: SizedBox.shrink(),
                    child: Chip(label: Text(syllable)),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    width: 280,
                    height: 80,
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        selectedSyllables.join('-'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
                onAcceptWithDetails: (details) {
                  String data = details.data;
                  if (!selectedSyllables.contains(data)) {
                    setState(() {
                      selectedSyllables.add(data);
                      availableSyllables.remove(data);
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: checkAnswer,
                    child: Text('Confirmar'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      resetGame();
                    },
                    child: Text('Limpar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}