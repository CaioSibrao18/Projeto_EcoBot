import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quizeasy_logic.dart';

class QuizScreenEasy extends StatefulWidget {
  const QuizScreenEasy({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreenEasy> {
  late QuizEasyLogic gameLogic;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    
    gameLogic = QuizEasyLogic(
      questions: const [
        {
          "question": "Qual cor de lixeira é usada para papel?",
          "options": ["Azul", "Vermelha", "Verde"],
          "correctIndex": 0,  
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
      ],
    );
  }

  void checkAnswer(int index) {
    setState(() {
      gameLogic.checkAnswer(index);
      
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          if (!gameLogic.isGameOver()) {
            gameLogic.nextQuestion();
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
        var data = json.decode(response.body);

        if (data['analysis'] != null && data['analysis']['feedback'] != null) {
          data['analysis']['feedback'] = [
            "🎯 Feedback personalizado - Nível Fácil",
            "🚀 Ótimo começo na jornada da reciclagem!",
            "💡 Dica: pratique a separação dos resíduos em casa",
            "IA: análise simplificada para iniciantes",
          ];
        }

        if (data['analysis'] != null &&
            data['analysis']['current_period'] != null) {
          data['analysis']['current_period']['accuracy_avg'] = 95.0;
        }

        return data;
      }
    } catch (e) {
      print('Erro ao obter análise da IA: $e');
    }
    return null;
  }

  void _showResult() async {
    final results = gameLogic.getGameResults();
    int tempoSegundos = results['timeInSeconds'];

    setState(() {
      _isLoading = true;
    });

    await _enviarParaBackend(results['correctAnswers'], tempoSegundos);
    final analysisData = await _getAIAnalysis();

    setState(() {
      _analysisData = analysisData;
      _isLoading = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                  'Resultado - Nível Fácil',
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
                      gameLogic.resetGame();
                      _analysisData = null;
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
    Widget _buildStatWithExplanation(
      String title,
      String? value,
      String explanation,
      Color color,
    ) {
      if (value == null || value == 'N/A') return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: $value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'PressStart2P',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              explanation,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    final analysis = _analysisData?['analysis'];
    final currentPeriod = analysis?['current_period'];
    final previousPeriod = analysis?['previous_period'];
    final trends = analysis?['trends'];
    final feedbackList = analysis?['feedback'] ?? [];

    Widget _buildSectionTitle(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.blueAccent,
          ),
        ),
      );
    }

    Widget _buildCurrentResult() {
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: const Color(0xFFE8F5E9),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'QUIZ CONCLUÍDO!',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2BB462),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Resumo do Quiz Recém Finalizado',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 18),
              _buildStatWithExplanation(
                'Pontuação',
                currentPeriod?['best_score']?.toString(),
                'Sua pontuação neste quiz',
                Colors.green.shade700,
              ),
              _buildStatWithExplanation(
                'Consistência',
                currentPeriod?['consistency'] != null
                    ? currentPeriod!['consistency'].toStringAsFixed(2)
                    : null,
                'Quanto menor, mais consistente',
                Colors.orange.shade700,
              ),
              _buildStatWithExplanation(
                'Tentativas',
                currentPeriod?['count']?.toString(),
                'Número de tentativas realizadas',
                Colors.purple.shade700,
              ),
              _buildStatWithExplanation(
                'Velocidade Média',
                currentPeriod?['speed_avg'] != null
                    ? '${currentPeriod!['speed_avg'].toStringAsFixed(2)}s'
                    : null,
                'Tempo médio por questão',
                Colors.red.shade700,
              ),
              const SizedBox(height: 20),
              Text(
                '${gameLogic.correctAnswers}/${gameLogic.questions.length} corretas',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tempo: $tempoSegundos segundos',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTrendItem(String title, double? value) {
      if (value == null) return const SizedBox.shrink();
      final isPositive = value >= 0;
      final display = isPositive ? '+${value.toStringAsFixed(2)}' : value.toStringAsFixed(2);
      final color = isPositive ? Colors.green : Colors.red;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              display,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildStatsCard(String title, List<Widget> stats) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  letterSpacing: 1.2,
                ),
              ),
              const Divider(color: Colors.grey, height: 18),
              ...stats,
            ],
          ),
        ),
      );
    }

    Widget _buildFeedbackList(List<dynamic> feedbacks) {
      if (feedbacks.isEmpty) {
        return const Text(
          'Nenhum feedback disponível.',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 12,
            color: Colors.black45,
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: feedbacks.map<Widget>((fb) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '• ${fb.toString()}',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          )).toList(),
        ),
      );
    }

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF2BB462)),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentResult(),
                if (previousPeriod != null) ...[
                  _buildSectionTitle('HISTÓRICO DESEMPENHO'),
                  _buildStatsCard('Período Anterior', [
                    _buildStatWithExplanation(
                      'Pontuação Anterior',
                      previousPeriod['best_score']?.toString(),
                      'Sua pontuação anterior',
                      Colors.green[700]!,
                    ),
                    _buildStatWithExplanation(
                      'Consistência Anterior',
                      previousPeriod['consistency']?.toStringAsFixed(2),
                      'Estabilidade anterior dos resultados',
                      Colors.orange[700]!,
                    ),
                    _buildStatWithExplanation(
                      'Tentativas Anteriores',
                      previousPeriod['count']?.toString(),
                      'Número de quizzes anteriores',
                      Colors.purple[700]!,
                    ),
                    _buildStatWithExplanation(
                      'Velocidade Anterior',
                      previousPeriod['speed_avg'] != null
                          ? '${previousPeriod['speed_avg'].toStringAsFixed(2)}s'
                          : null,
                      'Tempo médio anterior por questão',
                      Colors.red[700]!,
                    ),
                  ]),
                ],
                if (trends != null) ...[
                  _buildSectionTitle('TENDÊNCIAS'),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _buildTrendItem(
                            'Precisão',
                            (trends['accuracy'] as num?)?.toDouble(),
                          ),
                          _buildTrendItem(
                            'Consistência',
                            (trends['consistency'] as num?)?.toDouble(),
                          ),
                          _buildTrendItem(
                            'Velocidade',
                            (trends['speed'] as num?)?.toDouble(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                _buildSectionTitle('RECOMENDAÇÕES'),
                _buildFeedbackList(feedbackList),
                const SizedBox(height: 40),
              ],
            ),
          );
  }

  Widget _buildOptionButton(int index, String option, bool isCorrect) {
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFF2BB462);
    Color textColor = Colors.black;

    if (gameLogic.selectedOption != null) {
      if (index == gameLogic.selectedOption) {
        backgroundColor = isCorrect ? Colors.green : Colors.red;
        textColor = Colors.white;
      } else if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.3);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: gameLogic.selectedOption == null ? () => checkAnswer(index) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 14,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var questionData = gameLogic.getCurrentQuestion();
    bool isCorrect = gameLogic.selectedOption == questionData['correctIndex'];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: SafeArea(
        child: Column(
          children: [
            // Botão de voltar ao menu
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF2BB462), size: 32),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/menu_games');
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.asset(
                'assets/images/logoEcoQuest.png',
                width: 160,
                height: 160,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2BB462), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        questionData['question'],
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(questionData['options'].length, (index) {
                      return _buildOptionButton(
                        index,
                        questionData['options'][index],
                        index == questionData['correctIndex'],
                      );
                    }),
                    if (gameLogic.selectedOption != null && !isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Resposta correta: ${questionData['options'][questionData['correctIndex']]}',
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 12,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Pergunta ${gameLogic.currentQuestionIndex + 1} de ${gameLogic.questions.length}',
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        color: Color(0xFF2BB462),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}