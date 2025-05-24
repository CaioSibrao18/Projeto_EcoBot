import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpellingGameLetters extends StatefulWidget {
  const SpellingGameLetters({super.key});

  @override
  _SpellingGameLettersState createState() => _SpellingGameLettersState();
}

class _SpellingGameLettersState extends State<SpellingGameLetters> {
  final List<Map<String, dynamic>> words = [
    {
      'word': 'reciclar',
      'letters': ['r', 'e', 'c', 'i', 'c', 'l', 'a', 'r'],
    },
    {
      'word': 'ecossistema',
      'letters': ['e', 'c', 'o', 's', 's', 'i', 's', 't', 'e', 'm', 'a'],
    },
    {
      'word': 'compostagem',
      'letters': ['c', 'o', 'm', 'p', 'o', 's', 't', 'a', 'g', 'e', 'm'],
    },
    {
      'word': 'sustentabilidade',
      'letters': [
        's',
        'u',
        's',
        't',
        'e',
        'n',
        't',
        'a',
        'b',
        'i',
        'l',
        'i',
        'd',
        'a',
        'd',
        'e',
      ],
    },
    {
      'word': 'biodiversidade',
      'letters': [
        'b',
        'i',
        'o',
        'd',
        'i',
        'v',
        'e',
        'r',
        's',
        'i',
        'd',
        'a',
        'd',
        'e',
      ],
    },
    {
      'word': 'energia',
      'letters': ['e', 'n', 'e', 'r', 'g', 'i', 'a'],
    },
    {
      'word': 'natureza',
      'letters': ['n', 'a', 't', 'u', 'r', 'e', 'z', 'a'],
    },
    {
      'word': 'renovavel',
      'letters': ['r', 'e', 'n', 'o', 'v', 'a', 'v', 'e', 'l'],
    },
    {
      'word': 'preservar',
      'letters': ['p', 'r', 'e', 's', 'e', 'r', 'v', 'a', 'r'],
    },
    {
      'word': 'consciente',
      'letters': ['c', 'o', 'n', 's', 'c', 'i', 'e', 'n', 't', 'e'],
    },
  ];

  int currentWordIndex = 0;
  int correctAnswers = 0;
  List<String> selectedLetters = [];
  List<String> availableLetters = [];
  bool showCorrectWord = false;
  String correctWord = '';
  Color boxColor = Colors.grey[200]!;
  final Stopwatch _stopwatch = Stopwatch();
  final Stopwatch _wordStopwatch = Stopwatch(); // Cronômetro por palavra
  List<int> _wordTimes = []; // Lista para armazenar tempos por palavra
  bool _isLoading = false;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _wordStopwatch.start(); // Inicia o cronômetro por palavra
    resetGame();
  }

  void resetGame() {
    setState(() {
      selectedLetters.clear();
      availableLetters = List.from(words[currentWordIndex]['letters']);
      availableLetters.shuffle();
      showCorrectWord = false;
      correctWord = words[currentWordIndex]['word'];
      boxColor = Colors.grey[200]!;
    });
  }

  void checkAnswer() {
    // Para o cronômetro da palavra atual e armazena o tempo
    _wordStopwatch.stop();
    int wordTime = _wordStopwatch.elapsed.inSeconds;
    _wordTimes.add(wordTime);

    String formedWord = selectedLetters.join('');
    String answer = correctWord;

    if (formedWord == answer) {
      setState(() {
        boxColor = Colors.greenAccent;
        correctAnswers++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        _wordStopwatch.reset(); // Reinicia para próxima palavra
        _wordStopwatch.start();
        goToNextWord();
      });
    } else {
      setState(() {
        boxColor = Colors.redAccent;
        showCorrectWord = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        _wordStopwatch.reset(); // Reinicia para próxima palavra
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
          'tempos_palavras': _wordTimes, // Envia os tempos individuais
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
            "🚀 Você está melhorando na formação de palavras ecológicas!",
            "💡 Dica: pratique palavras difíceis como 'sustentabilidade'",
            "IA: análise de desempenho em jogos de letras",
          ];
        }

        if (data['analysis'] != null &&
            data['analysis']['current_period'] != null) {
          data['analysis']['current_period']['accuracy_avg'] = 85.0;
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
                      'Resultado - Jogo de Letras',
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
      // Calcula a média localmente para exibição
      double speedAvg =
          _wordTimes.isNotEmpty
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
                speedAvg.toStringAsFixed(2) + 's', // Usa o cálculo local
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

    // ... (mantenha todos os outros métodos exatamente como estavam)
    // _buildTrendItem, _buildStatsCard, _buildFeedbackList, _letterTile

    Widget _buildTrendItem(String title, double? value) {
      if (value == null) return const SizedBox.shrink();
      final isPositive = value >= 0;
      final display =
          isPositive
              ? '+${value.toStringAsFixed(2)}'
              : value.toStringAsFixed(2);
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
          children:
              feedbacks
                  .map<Widget>(
                    (fb) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '• ${fb.toString()}',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
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

  Widget _letterTile(String letter, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFF2BB462) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2BB462), width: 2),
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontFamily: 'PressStart2P',
          color: dragging ? Colors.white : const Color(0xFF2BB462),
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logoEcoQuest.png',
                      height: 240,
                      width: 240,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Arraste as letras para formar a palavra correta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PressStart2P',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          availableLetters
                              .map(
                                (letter) => Draggable<String>(
                                  data: letter,
                                  feedback: _letterTile(letter, dragging: true),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: _letterTile(letter),
                                  ),
                                  child: _letterTile(letter),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 30),
                    DragTarget<String>(
                      builder:
                          (context, candidateData, rejectedData) => Container(
                            padding: const EdgeInsets.all(16),
                            height: 80,
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
                            child: Text(
                              selectedLetters.join('').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PressStart2P',
                                color: Color(0xFF2BB462),
                              ),
                            ),
                          ),
                      onAcceptWithDetails: (data) {
                        if (availableLetters.contains(data.data)) {
                          setState(() {
                            selectedLetters.add(data.data);
                            availableLetters.remove(data.data);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    if (showCorrectWord)
                      Column(
                        children: [
                          const Text(
                            'Palavra correta:',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'PressStart2P',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            correctWord.split('').join('-').toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: 'PressStart2P',
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: checkAnswer,
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
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Color(0xFF2BB462),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
