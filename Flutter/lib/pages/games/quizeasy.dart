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
  bool _isLoading = false;
  Map<String, dynamic>? _analysisData;

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

  Future<void> _enviarParaBackend(int acertos, int tempoSegundos) async {
    try {
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
    } catch (e) {
      print('Erro ao enviar resultados: $e');
    }
  }

  Future<Map<String, dynamic>?> _getAIAnalysis() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/results/feedback?usuario_id=4'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Erro ao obter análise da IA: $e');
    }
    return null;
  }

  void _showResult() async {
    _stopwatch.stop();
    int tempoSegundos = _stopwatch.elapsed.inSeconds;

    setState(() {
      _isLoading = true;
    });

    await _enviarParaBackend(correctAnswers, tempoSegundos);
    final analysisData = await _getAIAnalysis();

    setState(() {
      _analysisData = analysisData;
      _isLoading = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFFFDFDF7),
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Resultado',
                      style: const TextStyle(
                        color: Color(0xFF2BB462),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PressStart2P',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildResultsContent(tempoSegundos),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          currentQuestionIndex = 0;
                          correctAnswers = 0;
                          _analysisData = null;
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
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildResultsContent(int tempoSegundos) {
    final currentPeriod = _analysisData?['analysis']?['current_period'];
    final feedbackList = _analysisData?['analysis']?['feedback'] ?? [];
    final aiFeedback =
        _analysisData?['analysis']?['feedback_detail']?['ai']?['messages'] ??
        [];

    return _isLoading
        ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF2BB462)),
        )
        : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acertos: $correctAnswers/${questions.length}',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Tempo: $tempoSegundos segundos',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Status: sucesso',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Color(0xFF2BB462),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '📊 Estatísticas atuais:',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (currentPeriod != null) ...[
              _buildStatItem(
                'Precisão média:',
                '${currentPeriod['accuracy_avg']?.toStringAsFixed(2) ?? 'N/A'}% (acertos gerais no período)',
              ),
              _buildStatItem(
                'Melhor pontuação:',
                '${currentPeriod['best_score']?.toStringAsFixed(2) ?? 'N/A'} (melhor resultado alcançado)',
              ),
              _buildStatItem(
                'Consistência:',
                '${currentPeriod['consistency']?.toStringAsFixed(2) ?? 'N/A'} (estabilidade dos resultados)',
              ),
              _buildStatItem(
                'Tentativas:',
                '${currentPeriod['count'] ?? 'N/A'} (quantidade de jogos feitos)',
              ),
              _buildStatItem(
                'Velocidade média:',
                '${currentPeriod['speed_avg']?.toStringAsFixed(2) ?? 'N/A'} segundos por item',
              ),
            ],
            const SizedBox(height: 20),

            const Text(
              '💬 Feedback da IA:',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (aiFeedback.isNotEmpty)
              ...aiFeedback.map((feedback) => _buildFeedbackItem(feedback))
            else if (feedbackList.isNotEmpty)
              ...feedbackList.map((feedback) => _buildFeedbackItem(feedback))
            else
              _buildDefaultFeedback(correctAnswers, questions.length),
          ],
        );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: Colors.black,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFeedback(int correctAnswers, int totalQuestions) {
    double percentage = (correctAnswers / totalQuestions) * 100;
    String feedback;

    if (percentage == 0) {
      feedback = "🔄 Hora de praticar mais! Tente novamente.";
    } else if (percentage < 30) {
      feedback = "💡 Você está começando, continue praticando!";
    } else if (percentage < 70) {
      feedback = "👍 Bom trabalho! Você está melhorando!";
    } else if (percentage < 90) {
      feedback = "👏 Ótimo desempenho! Continue assim!";
    } else {
      feedback = "🎯 Excelente! Desempenho excepcional!";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        feedback,
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 10,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildFeedbackItem(dynamic feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        feedback?.toString() ?? '',
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 10,
          color: Colors.black,
        ),
      ),
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
                        selectedOption == null
                            ? () => checkAnswer(index)
                            : null,
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
