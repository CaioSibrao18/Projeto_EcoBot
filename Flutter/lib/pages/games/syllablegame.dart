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
    {'word': 'e-ner-gi-a', 'syllables': ['e', 'ner', 'gi', 'a']},
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
  late List<String> availableSyllables;
  List<String> selectedSyllables = [];
  Color boxColor = Colors.grey.shade200;
  String? incorrectWord;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      selectedSyllables = [];
      availableSyllables = List.from(words[currentWordIndex]['syllables']);
      availableSyllables.shuffle();
      boxColor = Colors.grey.shade200;
      incorrectWord = null;
    });
  }

  void checkAnswer() {
    final formedWord = selectedSyllables.join('-');
    final correctWord = words[currentWordIndex]['word'];

    if (formedWord == correctWord) {
      setState(() {
        boxColor = Colors.greenAccent;
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
        boxColor = Colors.redAccent;
        incorrectWord = correctWord;
      });
      Future.delayed(const Duration(seconds: 2), () {
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
    final percentage = (correctAnswers / words.length) * 100;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resultado', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario_id': 4,
        'acertos': acertos,
        'tempo_segundos': 0,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Resultado enviado com sucesso!');
    } else {
      print('Erro ao enviar o resultado: ${response.body}');
    }
  }

  Widget _syllableTile(String syllable, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFF2BB462) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2BB462), width: 2),
      ),
      child: Text(
        syllable,
        style: TextStyle(
          color: dragging ? Colors.white : const Color(0xFF2BB462),
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'PressStart2P',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfdf7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2bb462)),
          onPressed: () {
            setState(() {
              selectedSyllables.clear();
              availableSyllables.clear();
            });
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/logoEcoQuest.png', width: 240, height: 240),
              const SizedBox(height: 20),
              const Text(
                'Arraste as sílabas para formar a palavra correta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PressStart2P',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              /// Sílabas disponíveis
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: availableSyllables
                    .map(
                      (syllable) => Draggable<String>(
                        data: syllable,
                        feedback: _syllableTile(syllable, dragging: true),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _syllableTile(syllable),
                        ),
                        child: _syllableTile(syllable),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 40),

              /// Área de montagem
              DragTarget<String>(
                builder: (context, candidateData, rejectedData) => Container(
                  padding: const EdgeInsets.all(16),
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2BB462), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 8,
                    children: selectedSyllables
                        .map((syllable) => _syllableTile(syllable))
                        .toList(),
                  ),
                ),
                onWillAccept: (data) => true,
                onAccept: (data) {
                  if (!selectedSyllables.contains(data)) {
                    setState(() {
                      selectedSyllables.add(data);
                      availableSyllables.remove(data);
                    });
                  }
                },
              ),

              if (incorrectWord != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Palavra correta: $incorrectWord',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB462),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}