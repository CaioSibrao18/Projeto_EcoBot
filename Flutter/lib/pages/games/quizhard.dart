import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    // ... (mantenha o restante das perguntas)
  ];

  int currentQuestionIndex = 0;
  int? selectedOption;
  int correctAnswers = 0;
  int startTime = DateTime.now().millisecondsSinceEpoch;

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
    int endTime = DateTime.now().millisecondsSinceEpoch;
    int tempoSegundos = ((endTime - startTime) / 1000).toInt();

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
                  SizedBox(height: 15),
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
                    startTime = DateTime.now().millisecondsSinceEpoch;
                  });
                  _sendResultToBackend(correctAnswers, tempoSegundos);
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

  Future<void> _sendResultToBackend(int acertos, int tempoSegundos) async {
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
          'Game Quiz Difícil',
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
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                  SizedBox(height: 25),
                  Column(
                    children: List.generate(questionData['options'].length, (
                      index,
                    ) {
                      Color buttonColor = Colors.teal[400]!;
                      if (selectedOption != null) {
                        if (index == questionData['correctIndex']) {
                          buttonColor = Colors.green;
                        } else if (index == selectedOption) {
                          buttonColor = Colors.red;
                        }
                      }
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed:
                              selectedOption == null
                                  ? () => checkAnswer(index)
                                  : null,
                          child: Text(
                            questionData['options'][index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  ),
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
      ),
    );
  }
}
