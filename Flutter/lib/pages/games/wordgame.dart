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
      boxColor = Colors.grey[200]!;
    });
  }

  void checkAnswer() {
    String formedWord = selectedLetters.join('');
    String correctWord = words[currentWordIndex]['word'];

    if (formedWord == correctWord) {
      setState(() {
        boxColor = Colors.greenAccent;
        correctAnswers++;
      });
    } else {
      setState(() {
        boxColor = Colors.redAccent;
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (currentWordIndex < words.length - 1) {
        setState(() => currentWordIndex++);
        resetGame();
      } else {
        showResult();
      }
    });
  }

  void showResult() {
    double percentage = (correctAnswers / words.length) * 100;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Você acertou ${percentage.toStringAsFixed(1)}% das palavras!'),
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
            child: const Text('Tentar Novamente'),
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
      print('Erro ao enviar resultado: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    int half = (availableLetters.length / 2).ceil();

    List<String> topRowLetters = availableLetters.take(half).toList();
    List<String> bottomRowLetters = availableLetters.skip(half).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        title: const Text('Soletrar por Letras'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2BB462),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Arraste as letras para formar a palavra correta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: topRowLetters.map((letter) => Padding(
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
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bottomRowLetters.map((letter) => Padding(
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
            ),

            const SizedBox(height: 30),

            DragTarget<String>(
              builder: (context, candidateData, rejectedData) => Container(
                padding: const EdgeInsets.all(16),
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2BB462), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  selectedLetters.join(''),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PressStart2P',
                  ),
                ),
              ),
              onAccept: (data) {
                if (availableLetters.contains(data)) {
                  setState(() {
                    selectedLetters.add(data);
                    availableLetters.remove(data);
                  });
                }
              },
            ),

            const SizedBox(height: 30),

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
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
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