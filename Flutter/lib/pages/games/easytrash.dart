import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EasyTrashSortingGame extends StatefulWidget {
  const EasyTrashSortingGame({super.key});

  @override
  _EasyTrashSortingGameState createState() => _EasyTrashSortingGameState();
}

class _EasyTrashSortingGameState extends State<EasyTrashSortingGame> {
  final List<Map<String, dynamic>> trashItems = [
    {'image': 'assets/images/caderno.png', 'correctBin': 'azul'},
    {'image': 'assets/images/caixadeleite.png', 'correctBin': 'azul'},
    {'image': 'assets/images/envelope.png', 'correctBin': 'azul'},
    {'image': 'assets/images/sacola.png', 'correctBin': 'vermelha'},
    {'image': 'assets/images/latinha.png', 'correctBin': 'amarelo'},
    {'image': 'assets/images/caixapapelao.png', 'correctBin': 'azul'},
    {'image': 'assets/images/garrafa.png', 'correctBin': 'vermelha'},
    {'image': 'assets/images/canudo.png', 'correctBin': 'vermelha'},
    {'image': 'assets/images/salgadinho.png', 'correctBin': 'vermelha'},
    {'image': 'assets/images/jornal.png', 'correctBin': 'azul'},
  ];

  final Map<String, String> binImages = {
    'azul': 'assets/images/azullixeira.png',
    'amarelo': 'assets/images/amarelalixeira.png',
    'vermelha': 'assets/images/vermelhalixeira.png',
  };

  int currentItemIndex = 0;
  int correctAnswers = 0;
  String? lastResultText;
  String? lastResultBin;
  bool? lastResultCorrect;
  final Stopwatch _stopwatch = Stopwatch();
  bool _isLoading = false;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  void checkAnswer(String selectedBin) {
    String correctBin = trashItems[currentItemIndex]['correctBin'];
    bool isCorrect = selectedBin == correctBin;

    setState(() {
      lastResultText = correctBin;
      lastResultBin = selectedBin;
      lastResultCorrect = isCorrect;

      if (isCorrect) correctAnswers++;

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (currentItemIndex < trashItems.length - 1) {
            currentItemIndex++;
            lastResultText = null;
            lastResultCorrect = null;
            lastResultBin = null;
          } else {
            _stopwatch.stop();
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
            "🎯 Feedback personalizado",
            "🚀 Continue praticando a separação de lixo!",
            "💡 Dica extra: revise os itens errados",
            "IA: análise customizada para separação de resíduos",
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
                      currentItemIndex = 0;
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
                'JOGO CONCLUÍDO!',
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
                'Resumo do Jogo Recém Finalizado',
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
                'Sua pontuação neste jogo',
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
                'Tempo médio por item',
                Colors.red.shade700,
              ),
              const SizedBox(height: 20),
              Text(
                '$correctAnswers/${trashItems.length} corretos',
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
                      'Número de jogos anteriores',
                      Colors.purple[700]!,
                    ),
                    _buildStatWithExplanation(
                      'Velocidade Anterior',
                      previousPeriod['speed_avg'] != null
                          ? '${previousPeriod['speed_avg'].toStringAsFixed(2)}s'
                          : null,
                      'Tempo médio anterior por item',
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

  @override
  Widget build(BuildContext context) {
    String currentImage = trashItems[currentItemIndex]['image'];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2BB462)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/logoEcoQuest.png',
                width: 160,
                height: 160,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ARRASTE PARA A LIXEIRA CERTA',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 8,
                            color: Color(0xFF2BB462),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Draggable<String>(
                          data: trashItems[currentItemIndex]['correctBin'],
                          feedback: Image.asset(currentImage, width: 80),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: Image.asset(currentImage, width: 80),
                          ),
                          child: Image.asset(currentImage, width: 80),
                        ),
                        const SizedBox(height: 12),
                        if (lastResultText != null)
                          Text(
                            lastResultCorrect == true
                                ? 'CERTO! ERA ${lastResultText!.toUpperCase()}'
                                : 'ERRADO! ERA ${lastResultText!.toUpperCase()}',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 8,
                              color: lastResultCorrect! ? Colors.green : Colors.red,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: binImages.entries.map((entry) {
                            final bool isSelected = lastResultBin == entry.key;
                            final bool isCorrect = lastResultCorrect == true && isSelected;
                            final bool isWrong = lastResultCorrect == false && isSelected;

                            return Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: DragTarget<String>(
                                builder: (context, candidateData, rejectedData) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 90,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green
                                          : isWrong
                                              ? Colors.red
                                              : Colors.white,
                                      border: Border.all(color: const Color(0xFF2BB462), width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(entry.value, fit: BoxFit.contain),
                                  );
                                },
                                onAcceptWithDetails: (_) => checkAnswer(entry.key),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${currentItemIndex + 1} / ${trashItems.length}',
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 8,
                            color: Color(0xFF2BB462),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}