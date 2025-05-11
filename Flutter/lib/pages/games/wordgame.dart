import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: SpellingGameLetters()));
}

class SpellingGameLetters extends StatefulWidget {
  const SpellingGameLetters({super.key});

  @override
  _SpellingGameLettersState createState() => _SpellingGameLettersState();
}

class _SpellingGameLettersState extends State<SpellingGameLetters> {
  final List<Map<String, dynamic>> words = [
    {'word': 'ecossistema', 'letters': ['e', 'c', 'o', 's', 's', 'i', 's', 't', 'e', 'm', 'a']},
    {'word': 'fotossintese', 'letters': ['f', 'o', 't', 'o', 's', 's', 'i', 'n', 't', 'e', 's', 'e']},
    {'word': 'sustentavel', 'letters': ['s', 'u', 's', 't', 'e', 'n', 't', 'a', 'v', 'e', 'l']},
    {'word': 'biodiverso', 'letters': ['b', 'i', 'o', 'd', 'i', 'v', 'e', 'r', 's', 'o']},
    {'word': 'renovavel', 'letters': ['r', 'e', 'n', 'o', 'v', 'a', 'v', 'e', 'l']},
    {'word': 'carbono', 'letters': ['c', 'a', 'r', 'b', 'o', 'n', 'o']},
    {'word': 'geotermica', 'letters': ['g', 'e', 'o', 't', 'e', 'r', 'm', 'i', 'c', 'a']},
    {'word': 'compostagem', 'letters': ['c', 'o', 'm', 'p', 'o', 's', 't', 'a', 'g', 'e', 'm']},
    {'word': 'ambiental', 'letters': ['a', 'm', 'b', 'i', 'e', 'n', 't', 'a', 'l']},
    {'word': 'fotovoltaico', 'letters': ['f', 'o', 't', 'o', 'v', 'o', 'l', 't', 'a', 'i', 'c', 'o']},
  ];

  int currentWordIndex = 0;
  int correctAnswers = 0;
  List<String> selectedLetters = [];
  List<String> availableLetters = [];
  Color boxColor = Colors.grey[300]!;

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
      boxColor = Colors.grey[300]!;
    });
  }

  void checkAnswer() {
    String formedWord = selectedLetters.join('');
    String correctWord = words[currentWordIndex]['word'];

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
      appBar: AppBar(title: Text('Soletrar por Letras')),
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
                children: availableLetters.map<Widget>((letter) {
                  return Material(
                    child: Draggable<String>(
                      data: letter,
                      feedback: Material(
                        child: Chip(
                          label: Text(
                            letter,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      childWhenDragging: SizedBox.shrink(),
                      child: Chip(
                        label: Text(
                          letter,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                      selectedLetters.join(''),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                onAcceptWithDetails: (data) {
                  setState(() {
                    selectedLetters.add(data.data);
                    availableLetters.remove(data.data);
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: checkAnswer, child: Text('Confirmar')),
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