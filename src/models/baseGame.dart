import 'package:flutter/material.dart';

abstract class JogoBase extends StatefulWidget {
  @override
  State<JogoBase> createState();
}

class _JogoBaseState extends State<JogoBase> {
  List<Map<String, dynamic>> palavras = [];
  int indicePalavra = 0;
  int acertos = 0;
  int totalTentativas = 0;
  List<String> elementos = [];
  List<String?> espacos = [];
  String palavraCorreta = "";

  @override
  void initState() {
    super.initState();
    _escolherPalavra();
  }

  void _escolherPalavra() {
    if (indicePalavra < palavras.length) {
      setState(() {
        var palavraEscolhida = palavras[indicePalavra];
        palavraCorreta = palavraEscolhida["palavra"];
        elementos = List.from(palavraEscolhida["elementos"]);
        elementos.shuffle();
        espacos = List.filled(elementos.length, null);
      });
    } else {
      _mostrarResultadoFinal();
    }
  }

  void _verificarPalavra() {
    if (!espacos.contains(null)) {
      totalTentativas++;

      if (espacos.join() == palavraCorreta) {
        acertos++;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parabéns! Você acertou!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Você errou! A palavra correta era: $palavraCorreta"),
          ),
        );
      }

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          indicePalavra++;
        });
        _escolherPalavra();
      });
    }
  }

  void _mostrarResultadoFinal() {
    double porcentagemAcertos =
        totalTentativas > 0 ? (acertos / totalTentativas) * 100 : 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Fim do Jogo"),
          content: Text(
            "Você acertou $acertos de $totalTentativas palavras.\n"
            "Porcentagem de acertos: ${porcentagemAcertos.toStringAsFixed(2)}%",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Voltar para a tela inicial
              },
              child: const Text("Voltar ao início"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getTitulo())),
      body: indicePalavra < palavras.length
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 10,
                  children: elementos.map((elemento) {
                    return Draggable<String>(
                      data: elemento,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Text(
                          elemento,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: Text(
                          elemento,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      child: Text(
                        elemento,
                        style: const TextStyle(fontSize: 24),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(espacos.length, (index) {
                    return DragTarget<String>(
                      onAccept: (data) {
                        setState(() {
                          espacos[index] = data;
                        });
                        _verificarPalavra();
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: espacos[index] != null
                                ? Colors.blue[200]
                                : Colors.white,
                          ),
                          child: Text(
                            espacos[index] ?? "_",
                            style: const TextStyle(fontSize: 24),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  String getTitulo();
}