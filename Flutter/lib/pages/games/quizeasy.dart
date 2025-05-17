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
    _stopwatch.stop();
    int tempoSegundos = _stopwatch.elapsed.inSeconds;
    _enviarParaBackend(correctAnswers, tempoSegundos);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Resultado',
              style: TextStyle(
                color: Colors.teal[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$correctAnswers/${questions.length} perguntas corretas',
                    style: TextStyle(fontSize: 18, color: Colors.teal[900]),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    correctAnswers > questions.length / 3
                        ? 'Parabéns, você domina o assunto!'
                        : 'Você ainda pode melhorar, continue estudando!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                      fontSize: 16,
                    ),
                  ),
                ],
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
                child: Text(
                  'Reiniciar',
                  style: TextStyle(color: Colors.teal[700]),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _enviarParaBackend(int acertos, int tempoSegundos) async {
    final url = Uri.parse('http://localhost:5000/api/saveResult');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario_id': 4,
        'acertos': acertos,
        'tempo_segundos': tempoSegundos,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Resultado enviado com sucesso!');
    } else {
      print('Erro ao enviar o resultado: ${response.body}');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    var questionData = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(
          'Game Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    questionData['question'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),
                ...List.generate(questionData['options'].length, (index) {
                  Color buttonColor = Colors.teal[400]!;
                  if (selectedOption != null) {
                    if (index == questionData['correctIndex']) {
                      buttonColor =
                          Colors.green; 
                    } else if (index == selectedOption) {
                      buttonColor =
                          Colors.red; 
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              buttonColor,
                            ),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            elevation: WidgetStateProperty.all(3),
                            shadowColor: WidgetStateProperty.all(
                              Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          onPressed:
                              selectedOption == null
                                  ? () => checkAnswer(index)
                                  : null,
                          child: Text(
                            questionData['options'][index],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
                Text(
                  'Pergunta ${currentQuestionIndex + 1} de ${questions.length}',
                  style: TextStyle(
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
}
