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
    {
      'word': 'a-ma-zô-nia',
      'syllables': ['a', 'ma', 'zô', 'nia'],
    },
    {
      'word': 'a-gua',
      'syllables': ['a', 'gua'],
    },
    {
      'word': 'na-tu-re-za',
      'syllables': ['na', 'tu', 're', 'za'],
    },
    {
      'word': 'po-lu-i-ção',
      'syllables': ['po', 'lu', 'i', 'ção'],
    },
    {
      'word': 're-u-ti-li-zar',
      'syllables': ['re', 'u', 'ti', 'li', 'zar'],
    },
    {
      'word': 'com-pos-ta-gem',
      'syllables': ['com', 'pos', 'ta', 'gem'],
    },
    {
      'word': 'bio-de-gra-dá-vel',
      'syllables': ['bio', 'de', 'gra', 'dá', 'vel'],
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
      builder:
          (context) => AlertDialog(
            title: Text(
              'Resultado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Você acertou ${percentage.toStringAsFixed(1)}% das palavras!',
                style: TextStyle(fontSize: 18),
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
                  style: TextStyle(color: Colors.blue[800]),
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
          'Soletrar por Sílabas',
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
                      availableSyllables.map<Widget>((syllable) {
                        return Draggable<String>(
                          data: syllable,
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
                                syllable,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: _buildSyllableChip(syllable),
                          ),
                          child: _buildSyllableChip(syllable),
                        );
                      }).toList(),
                ),
                SizedBox(height: 30),
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 100,
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
                        selectedSyllables.join('-'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
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
                    color: Colors.grey[700],
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

  Widget _buildSyllableChip(String syllable) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.teal[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal[400]!, width: 1.5),
      ),
      child: Text(
        syllable,
        style: TextStyle(
          fontSize: 18,
          color: Colors.teal[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
