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
    {
      'word': 'ecossistema',
      'letters': ['e', 'c', 'o', 's', 's', 'i', 's', 't', 'e', 'm', 'a'],
    },
    {
      'word': 'fotossintese',
      'letters': ['f', 'o', 't', 'o', 's', 's', 'i', 'n', 't', 'e', 's', 'e'],
    },
    {
      'word': 'sustentavel',
      'letters': ['s', 'u', 's', 't', 'e', 'n', 't', 'a', 'v', 'e', 'l'],
    },
    {
      'word': 'biodiverso',
      'letters': ['b', 'i', 'o', 'd', 'i', 'v', 'e', 'r', 's', 'o'],
    },
    {
      'word': 'renovavel',
      'letters': ['r', 'e', 'n', 'o', 'v', 'a', 'v', 'e', 'l'],
    },
    {
      'word': 'carbono',
      'letters': ['c', 'a', 'r', 'b', 'o', 'n', 'o'],
    },
    {
      'word': 'geotermica',
      'letters': ['g', 'e', 'o', 't', 'e', 'r', 'm', 'i', 'c', 'a'],
    },
    {
      'word': 'compostagem',
      'letters': ['c', 'o', 'm', 'p', 'o', 's', 't', 'a', 'g', 'e', 'm'],
    },
    {
      'word': 'ambiental',
      'letters': ['a', 'm', 'b', 'i', 'e', 'n', 't', 'a', 'l'],
    },
    {
      'word': 'fotovoltaico',
      'letters': ['f', 'o', 't', 'o', 'v', 'o', 'l', 't', 'a', 'i', 'c', 'o'],
    },
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
      builder:
          (context) => AlertDialog(
            title: Text(
              'Resultado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            content: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Você acertou ${percentage.toStringAsFixed(1)}% das palavras!',
                style: TextStyle(fontSize: 18, color: Colors.teal[900]),
              ),
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
                child: Text(
                  'Tentar Novamente',
                  style: TextStyle(color: Colors.teal[700]),
                ),
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
      appBar: AppBar(
        title: Text(
          'Soletrar por Letras',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Monte a palavra corretamente:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      availableLetters.map<Widget>((letter) {
                        return Draggable<String>(
                          data: letter,
                          feedback: Material(
                            elevation: 4,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal[400],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Text(
                                letter.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: _buildLetterChip(letter),
                          ),
                          child: _buildLetterChip(letter),
                        );
                      }).toList(),
                ),
                SizedBox(height: 30),
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 70,
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.teal[800]!, width: 2),
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
                        selectedLetters.join(''),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
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
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Limpar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Palavra ${currentWordIndex + 1} de ${words.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterChip(String letter) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.teal[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal[400]!, width: 1.5),
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: 22,
          color: Colors.teal[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
