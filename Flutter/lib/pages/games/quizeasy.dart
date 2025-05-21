import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizScreenEasy extends StatefulWidget {
  const QuizScreenEasy({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreenEasy> {
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Qual cor de lixeira é usada para plástico?",
      "options": ["Azul", "Vermelha", "Verde"],
      "correctIndex": 1,
    },
    {
      "question": "O vidro pode ser reciclado?",
      "options": ["Sim", "Não", "Somente garrafas"],
      "correctIndex": 0,
    },
    {
      "question": "Onde devemos jogar uma lata de refrigerante?",
      "options": ["Lixeira amarela", "Lixeira azul", "Lixeira verde"],
      "correctIndex": 0,
    },
    {
      "question": "Qual destes materiais é reciclável?",
      "options": ["Casca de banana", "Garrafa PET", "Guardanapo sujo"],
      "correctIndex": 1,
    },
    {
      "question": "O que fazer com pilhas usadas?",
      "options": [
        "Jogar no lixo comum",
        "Levar a um ponto de coleta",
        "Enterrar no quintal",
      ],
      "correctIndex": 1,
    },
    {
      "question": "Qual é o destino correto para papelão?",
      "options": ["Lixeira azul", "Lixeira vermelha", "Lixeira verde"],
      "correctIndex": 0,
    },
    {
      "question": "Qual destes itens NÃO pode ser reciclado?",
      "options": ["Pote de vidro", "Papel higiênico usado", "Garrafa plástica"],
      "correctIndex": 1,
    },
    {
      "question": "Qual o principal benefício da reciclagem?",
      "options": ["Reduzir a poluição", "Aumentar o lixo", "Poluir rios"],
      "correctIndex": 0,
    },
    {
      "question": "Podemos jogar óleo de cozinha usado na pia?",
      "options": ["Sim", "Não", "Somente óleo novo"],
      "correctIndex": 1,
    },
    {
      "question": "Reciclar ajuda a:",
      "options": [
        "Preservar o meio ambiente",
        "Aumentar a poluição",
        "Desperdiçar recursos",
      ],
      "correctIndex": 0,
    },
  ];

  int currentQuestionIndex = 0;
  int? selectedOption;
  int correctAnswers = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  void checkAnswer(int index) {
    setState(() {
      selectedOption = index;
      bool isCorrect = index == questions[currentQuestionIndex]['correctIndex'];
      if (isCorrect) {
        correctAnswers++;
      }
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          selectedOption = null;
          if (currentQuestionIndex < questions.length - 1) {
            currentQuestionIndex++;
          } else {
            _showResult();
          }
        });
      });
    });
  }

  void _showResult() {
    _stopwatch.stop();
    int tempoSegundos = _stopwatch.elapsed.inSeconds;
    _enviarParaBackend(correctAnswers, tempoSegundos);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFDF7),
        title: const Text(
          'Resultado',
          style: TextStyle(
            color: Color(0xFF2BB462),
            fontWeight: FontWeight.bold,
            fontFamily: 'PressStart2P',
            fontSize: 14,
          ),
        ),
        content: Text(
          '$correctAnswers/${questions.length} corretas',
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 12,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentQuestionIndex = 0;
                correctAnswers = 0;
                _stopwatch.reset();
                _stopwatch.start();
              });
            },
            child: const Text(
              'Reiniciar',
              style: TextStyle(
                color: Color(0xFF2BB462),
                fontFamily: 'PressStart2P',
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _enviarParaBackend(int acertos, int tempoSegundos) async {
    final url = Uri.parse('http://localhost:5000/api/saveResult');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario_id': 4,
        'acertos': acertos,
        'tempo_segundos': tempoSegundos,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var questionData = questions[currentQuestionIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2BB462)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logoEcoQuest.png',
                width: 240,
                height: 240,
              ),
              const SizedBox(height: 16),
              Text(
                questionData['question'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'PressStart2P',
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(questionData['options'].length, (index) {
                Color backgroundColor = Colors.white;
                Color borderColor = Colors.blueGrey;
                Color textColor = Colors.black;

                if (selectedOption != null) {
                  if (index == questionData['correctIndex']) {
                    backgroundColor = Colors.green;
                    borderColor = Colors.green;
                    textColor = Colors.white;
                  } else if (index == selectedOption) {
                    backgroundColor = Colors.red;
                    borderColor = Colors.red;
                    textColor = Colors.white;
                  }
                } else {
                  backgroundColor = Colors.white;
                  borderColor = Colors.blueGrey;
                  textColor = Colors.black;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed:
                        selectedOption == null ? () => checkAnswer(index) : null,
                    child: Text(
                      questionData['options'][index],
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}