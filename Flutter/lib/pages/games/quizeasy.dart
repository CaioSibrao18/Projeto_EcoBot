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
        var data = json.decode(response.body);

        // EXEMPLO: Alterar o feedback para outra coisa
        if (data['analysis'] != null && data['analysis']['feedback'] != null) {
          data['analysis']['feedback'] = [
            "🎯 Feedback personalizado",
            "🚀 Continue praticando!",
            "💡 Dica extra: revise as perguntas erradas",
            "IA: análise customizada",
          ];
        }

        // Exemplo: alterar a precisão média atual
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
    // Função para construir o widget de estatística com explicação
    Widget _buildStatWithExplanation(
      String title,
      String? value,
      String explanation,
      Color color,
    ) {
      if (value == null || value == 'N/A') return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: $value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'PressStart2P',
                fontSize: 12,
              ),
            ),
            Text(
              explanation,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 10,
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

    // RESULTADO ATUAL DO JOGO (sempre visível primeiro)
    Widget _buildCurrentResult() {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'QUIZ CONCLUÍDO!',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2BB462),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Resumo do Jogo Recém Finalizado',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Usando _buildStatWithExplanation para cada estatística, filtrando null/'N/A'
            ...[
              _buildStatWithExplanation(
                'Precisão Média',
                currentPeriod?['accuracy_avg'] != null
                    ? '${currentPeriod!['accuracy_avg'].toStringAsFixed(2)}%'
                    : null,
                'Porcentagem média de acertos no jogo recém finalizado',
                Colors.blue,
              ),
              _buildStatWithExplanation(
                'Melhor Pontuação',
                currentPeriod?['best_score']?.toString(),
                'Sua melhor pontuação neste jogo',
                Colors.green,
              ),
              _buildStatWithExplanation(
                'Consistência',
                currentPeriod?['consistency'] != null
                    ? currentPeriod!['consistency'].toStringAsFixed(2)
                    : null,
                'Consistência dos seus resultados (quanto menor, melhor)',
                Colors.orange,
              ),
              _buildStatWithExplanation(
                'Tentativas',
                currentPeriod?['count']?.toString(),
                'Número de tentativas realizadas',
                Colors.purple,
              ),
              _buildStatWithExplanation(
                'Velocidade Média',
                currentPeriod?['speed_avg'] != null
                    ? '${currentPeriod!['speed_avg'].toStringAsFixed(2)}s'
                    : null,
                'Tempo médio gasto por questão',
                Colors.red,
              ),
            ].whereType<Widget>().toList(),

            const SizedBox(height: 12),

            Text(
              '$correctAnswers/${questions.length} corretas',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tempo: $tempoSegundos segundos',
              style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 12),
            ),
          ],
        ),
      );
    }

    Widget _buildTrendItem(String title, double? value) {
      if (value == null) return const SizedBox.shrink();
      String display =
          value >= 0
              ? '+${value.toStringAsFixed(2)}'
              : value.toStringAsFixed(2);
      Color color = value >= 0 ? Colors.green : Colors.red;

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              display,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return _isLoading
        ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF2BB462)),
        )
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resultado atual do jogo (SEMPRE NO TOPO)
              _buildCurrentResult(),
              const SizedBox(height: 20),

              // Análise detalhada (média histórica)
              if (currentPeriod != null) ...[
                const Text(
                  'ANÁLISE DETALHADA',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  _buildStatWithExplanation(
                    'Precisão',
                    currentPeriod['accuracy_avg'] != null
                        ? '${currentPeriod['accuracy_avg'].toStringAsFixed(2)}%'
                        : null,
                    'Porcentagem média de acertos em todas as tentativas',
                    Colors.blue,
                  ),
                  _buildStatWithExplanation(
                    'Melhor pontuação',
                    currentPeriod['best_score']?.toString(),
                    'Sua melhor pontuação alcançada neste período',
                    Colors.green,
                  ),
                  _buildStatWithExplanation(
                    'Consistência',
                    currentPeriod['consistency']?.toStringAsFixed(2),
                    'Quão consistentes foram seus resultados (quanto menor, mais consistente)',
                    Colors.orange,
                  ),
                  _buildStatWithExplanation(
                    'Tentativas',
                    currentPeriod['count']?.toString(),
                    'Número de vezes que você realizou o quiz neste período',
                    Colors.purple,
                  ),
                  _buildStatWithExplanation(
                    'Velocidade',
                    currentPeriod['speed_avg'] != null
                        ? '${currentPeriod['speed_avg'].toStringAsFixed(2)}s'
                        : null,
                    'Tempo médio gasto por questão (em segundos)',
                    Colors.red,
                  ),
                ].whereType<Widget>().toList(),
                const SizedBox(height: 20),
              ],

              // Histórico período anterior
              if (previousPeriod != null) ...[
                const Text(
                  'HISTÓRICO DESEMPENHO',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...[
                  _buildStatWithExplanation(
                    'Precisão Anterior',
                    previousPeriod['accuracy_avg'] != null
                        ? '${previousPeriod['accuracy_avg'].toStringAsFixed(2)}%'
                        : null,
                    'Porcentagem média de acertos no período anterior',
                    Colors.blueGrey,
                  ),
                  _buildStatWithExplanation(
                    'Melhor pontuação Anterior',
                    previousPeriod['best_score']?.toString(),
                    'Sua melhor pontuação no período anterior',
                    Colors.green[700]!,
                  ),
                  _buildStatWithExplanation(
                    'Consistência Anterior',
                    previousPeriod['consistency']?.toStringAsFixed(2),
                    'Consistência dos resultados anteriores',
                    Colors.orange[700]!,
                  ),
                  _buildStatWithExplanation(
                    'Tentativas Anteriores',
                    previousPeriod['count']?.toString(),
                    'Número de tentativas no período anterior',
                    Colors.purple[700]!,
                  ),
                  _buildStatWithExplanation(
                    'Velocidade Anterior',
                    previousPeriod['speed_avg'] != null
                        ? '${previousPeriod['speed_avg'].toStringAsFixed(2)}s'
                        : null,
                    'Tempo médio gasto por questão no período anterior',
                    Colors.red[700]!,
                  ),
                ].whereType<Widget>().toList(),
                const SizedBox(height: 20),
              ],

              // Tendências
              if (trends != null) ...[
                const Text(
                  'TENDÊNCIAS',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 20),
              ],

              // Feedback
              const Text(
                'RECOMENDAÇÕES',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (feedbackList.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        feedbackList
                            .map<Widget>(
                              (fb) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '• ${fb.toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ] else
                const Text(
                  'Nenhum feedback disponível.',
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
              const SizedBox(height: 40),
            ],
          ),
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
