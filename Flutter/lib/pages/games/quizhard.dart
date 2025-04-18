// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class QuizScreenHard extends StatefulWidget {
  const QuizScreenHard({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreenHard> {
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
    {
      'question':
          'Qual destes materiais demora mais tempo para se decompor na natureza?',
      'options': ['Papel', 'Vidro', 'Madeira', 'Alumínio'],
      'correctIndex': 1,
    },
    {
      'question': 'Qual das opções abaixo NÃO é uma prática sustentável?',
      'options': [
        'Usar sacolas reutilizáveis',
        'Consumir produtos locais e sazonais',
        'Desperdiçar água potável',
        'Reciclar materiais corretamente',
      ],
      'correctIndex': 2,
    },
    {
      "question":
          "Qual é a principal fonte de energia renovável utilizada no Brasil?",
      "options": ["Solar", "Eólica", "Hidrelétrica", "Biomassa"],
      "correctIndex": 2,
    },
    {
      "question":
          "O que significa a sigla 'ODS' no contexto da sustentabilidade?",
      "options": [
        "Objetivos de Desenvolvimento Sustentável",
        "Organização para Desenvolvimento Sustentável",
        "Oficina de Diretrizes Sustentáveis",
        "Operação de Defesa Socioambiental",
      ],
      "correctIndex": 0,
    },
    {
      "question": "O que é a pegada de carbono?",
      "options": [
        "Quantidade de carbono na atmosfera",
        "Medição do impacto ambiental causado por atividades humanas",
        "Quantidade de árvores necessárias para compensar poluição",
        "Índice de poluição das indústrias",
      ],
      "correctIndex": 1,
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
            padding: const EdgeInsets.all(16.0),
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
