// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Game Quiz 🌱',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/FundoVerde.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    questionData['question'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(questionData['options'].length, (index) {
                    Color buttonColor = const Color(0xFF4CAF50);
                    if (selectedOption != null) {
                      if (index == questionData['correctIndex']) {
                        buttonColor = const Color.fromARGB(255, 17, 116, 20);
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
                            backgroundColor: WidgetStateProperty.all(
                              buttonColor,
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 12),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          onPressed:
                              selectedOption == null
                                  ? () => checkAnswer(index)
                                  : null,
                          child: Text(
                            questionData['options'][index],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
