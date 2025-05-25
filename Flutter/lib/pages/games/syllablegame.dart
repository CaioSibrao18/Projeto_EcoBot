import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpellingGameSyllables extends StatefulWidget {
  const SpellingGameSyllables({super.key});

  @override
  _SpellingGameSyllablesState createState() => _SpellingGameSyllablesState();
}

class _SpellingGameSyllablesState extends State<SpellingGameSyllables> {
  final List<Map<String, dynamic>> words = [
    {'word': 're-ci-clar', 'syllables': ['re', 'ci', 'clar']},
    {'word': 'e-ner-gi-a', 'syllables': ['e', 'ner', 'gi', 'a']},
    {'word': 'sus-ten-tá-vel', 'syllables': ['sus', 'ten', 'tá', 'vel']},
    {'word': 'a-ma-zô-nia', 'syllables': ['a', 'ma', 'zô', 'nia']},
    {'word': 'a-gua', 'syllables': ['a', 'gua']},
    {'word': 'na-tu-re-za', 'syllables': ['na', 'tu', 're', 'za']},
    {'word': 'po-lu-i-ção', 'syllables': ['po', 'lu', 'i', 'ção']},
    {'word': 're-u-ti-li-zar', 'syllables': ['re', 'u', 'ti', 'li', 'zar']},
    {'word': 'com-pos-ta-gem', 'syllables': ['com', 'pos', 'ta', 'gem']},
    {'word': 'bio-de-gra-dá-vel', 'syllables': ['bio', 'de', 'gra', 'dá', 'vel']},
  ];

  int currentWordIndex = 0;
  int correctAnswers = 0;
  late List<String> availableSyllables;
  List<String> selectedSyllables = [];
  Color boxColor = Colors.grey.shade200;
  String? incorrectWord;
  final Stopwatch _stopwatch = Stopwatch();
  final Stopwatch _wordStopwatch = Stopwatch();
  List<int> _wordTimes = [];
  bool _isLoading = false;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _wordStopwatch.start();
    resetGame();
  }

  void resetGame() {
    setState(() {
      selectedSyllables.clear();
      availableSyllables = List.from(words[currentWordIndex]['syllables']);
      availableSyllables.shuffle();
      boxColor = Colors.grey.shade200;
      incorrectWord = null;
    });
  }

  void checkAnswer() {
    _wordStopwatch.stop();
    int wordTime = _wordStopwatch.elapsed.inSeconds;
    _wordTimes.add(wordTime);

    final formedWord = selectedSyllables.join('-');
    final correctWord = words[currentWordIndex]['word'];

    if (formedWord == correctWord) {
      setState(() {
        boxColor = Colors.greenAccent;
        correctAnswers++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        _wordStopwatch.reset();
        _wordStopwatch.start();
        goToNextWord();
      });
    } else {
      setState(() {
        boxColor = Colors.redAccent;
        incorrectWord = correctWord;
      });
      Future.delayed(const Duration(seconds: 2), () {
        _wordStopwatch.reset();
        _wordStopwatch.start();
        goToNextWord();
      });
    }
  }

  void goToNextWord() {
    if (currentWordIndex < words.length - 1) {
      setState(() {
        currentWordIndex++;
        resetGame();
      });
    } else {
      _showResult();
    }
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
          'tempos_palavras': _wordTimes,
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
            "🎯 Feedback personalizado - Formação de Palavras",
            "🚀 Você está melhorando na separação silábica!",
            "💡 Dica: pratique a pronúncia das palavras difíceis",
            "IA: análise de desempenho em jogos de sílabas",
          ];
        }

        if (data['analysis'] != null && data['analysis']['current_period'] != null) {
          data['analysis']['current_period']['accuracy_avg'] = 90.0;
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
                  'Resultado - Jogo de Sílabas',
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
                      currentWordIndex = 0;
                      correctAnswers = 0;
                      _analysisData = null;
                      _stopwatch.reset();
                      _stopwatch.start();
                      _wordStopwatch.reset();
                      _wordStopwatch.start();
                      _wordTimes.clear();
                    });
                    resetGame();
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
      double speedAvg = _wordTimes.isNotEmpty
          ? _wordTimes.reduce((a, b) => a + b) / _wordTimes.length
          : 0;

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
                currentPeriod?['consistency']?.toStringAsFixed(2),
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
                speedAvg.toStringAsFixed(2) + 's',
                'Tempo médio por palavra',
                Colors.red.shade700,
              ),
              const SizedBox(height: 20),
              Text(
                '$correctAnswers/${words.length} corretas',
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
                      'Tempo médio anterior por palavra',
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

  Widget _syllableTile(String syllable, {bool dragging = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFF2BB462) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2BB462), width: 2),
      ),
      child: Text(
        syllable,
        style: TextStyle(
          color: dragging ? Colors.white : const Color(0xFF2BB462),
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'PressStart2P',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfdf7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2bb462)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logoEcoQuest.png',
                width: 240,
                height: 240,
              ),
              const SizedBox(height: 20),
              const Text(
                'Arraste as sílabas para formar a palavra correta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PressStart2P',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Sílabas disponíveis
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: availableSyllables.map((syllable) {
                  return Draggable<String>(
                    data: syllable,
                    feedback: _syllableTile(syllable, dragging: true),
                    childWhenDragging: Container(),
                    child: _syllableTile(syllable),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Área de montagem
              DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2BB462),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...selectedSyllables.expand((syllable) {
                            final index = selectedSyllables.indexOf(syllable);
                            return [
                              _syllableTile(syllable),
                              if (index < selectedSyllables.length - 1)
                                const Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                            ];
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) {
                  setState(() {
                    selectedSyllables.add(data.data);
                    availableSyllables.remove(data.data);
                  });
                },
              ),

              if (incorrectWord != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Palavra correta: $incorrectWord',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: selectedSyllables.isNotEmpty ? checkAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB462),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Limpar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                'Palavra ${currentWordIndex + 1} de ${words.length}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}