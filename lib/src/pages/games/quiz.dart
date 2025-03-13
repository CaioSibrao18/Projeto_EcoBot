// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'A lata amarela é destinada a qual tipo de lixo?',
      'options': ['Papel', 'Vidro', 'Organico', 'Metal'],
      'correctIndex': 3,
    },
    {
      'question': 'Quanto tempo leva para o papel sumir no meio ambiente?',
      'options': [
        'Cerca de 400 anos',
        'Cerca de 100 anos',
        'Cerca de 60 anos',
        'Cerca de 1000 anos',
      ],
      'correctIndex': 0,
    },
    {
      'question':
          'Qual o tipo de lixo mais prejudicial se jogado ao meio ambiente?',
      'options': ['Restos de comida', 'Pilhas e baterias', 'Plástico', 'Papel'],
      'correctIndex': 1,
    },
  ];

  int currentQuestionIndex = 0;
  int? selectedOption;
  int correctAnswers = 0;

  void checkAnswer(int index) {
    setState(() {
      selectedOption = index;
      if (index == questions[currentQuestionIndex]['correctIndex']) {
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resultado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$correctAnswers/${questions.length} perguntas corretas'),
                const SizedBox(height: 10),
                Text(
                  correctAnswers > questions.length / 3
                      ? 'Parabéns, você domina o assunto!'
                      : 'Você ainda pode melhorar, continue estudando!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentQuestionIndex = 0;
                    correctAnswers = 0;
                  });
                },
                child: const Text('Reiniciar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var questionData = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('QUIZ GAME')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              questionData['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...List.generate(questionData['options'].length, (index) {
              Color buttonColor = Colors.blue;
              if (selectedOption != null) {
                if (index == questionData['correctIndex']) {
                  buttonColor = Colors.green;
                } else if (index == selectedOption) {
                  buttonColor = Colors.red;
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(buttonColor),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    onPressed:
                        selectedOption == null
                            ? () => checkAnswer(index)
                            : null,
                    child: Text(
                      questionData['options'][index],
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
