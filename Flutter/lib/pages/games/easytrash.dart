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
    {'name': 'Papel de caderno', 'correctBin': 'azul'},
    {'name': 'Lata de refrigerante', 'correctBin': 'amarelo'},
    {'name': 'Embalagem de salgadinho', 'correctBin': 'vermelho'},
    {'name': 'Revista', 'correctBin': 'azul'},
    {'name': 'Garrafa de suco', 'correctBin': 'amarelo'},
  ];

  final Map<String, Color> binColors = {
    'azul': Colors.blue,
    'amarelo': Colors.yellow,
    'vermelho': Colors.red,
  };

  int currentItemIndex = 0;
  int correctAnswers = 0;

  void checkAnswer(String selectedBin) {
    String correctBin = trashItems[currentItemIndex]['correctBin'];

    if (selectedBin == correctBin) {
      setState(() {
        correctAnswers++;
        if (currentItemIndex < trashItems.length - 1) {
          currentItemIndex++;
        } else {
          showResult();
        }
      });
    } else {
      showError(correctBin);
    }
  }

  void showError(String correctBin) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Resposta Errada',
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
              child: Text(
                'A lixeira correta era a ${correctBin.toUpperCase()}!',
                style: TextStyle(fontSize: 18, color: Colors.teal[900]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    if (currentItemIndex < trashItems.length - 1) {
                      currentItemIndex++;
                    } else {
                      showResult();
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Continuar',
                  style: TextStyle(color: Colors.teal[700]),
                ),
              ),
            ],
          ),
    );
  }

  void showResult() {
    double percentage = (correctAnswers / trashItems.length) * 100;
    _enviarParaBackend();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Fim do Jogo',
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
                    'Você acertou ${percentage.toStringAsFixed(1)}% dos objetos!',
                    style: TextStyle(fontSize: 18, color: Colors.teal[900]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    percentage > 50
                        ? 'Ótimo trabalho!'
                        : 'Continue praticando!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    currentItemIndex = 0;
                    correctAnswers = 0;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Jogar Novamente',
                  style: TextStyle(color: Colors.teal[700]),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _enviarParaBackend() async {
    final tempoSegundos = 60;
    final url = Uri.parse('http://localhost:5000/api/saveResult');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': 4,
          'acertos': correctAnswers,
          'tempo_segundos': tempoSegundos,
        }),
      );

      if (response.statusCode == 201) {
        print('Resultado enviado com sucesso');
      } else {
        print('Erro ao enviar: ${response.body}');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentObject = trashItems[currentItemIndex]['name'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(
          'Jogo da Separação do Lixo - Fácil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Arraste o objeto para a lixeira correta:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Draggable<String>(
                  data: currentObject,
                  feedback: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal[200],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        currentObject,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.teal[200]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentObject,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900]?.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentObject,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children:
                      binColors.keys.map((bin) {
                        return DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color:
                                      binColors[bin], // Mantém as cores originais
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  bin.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            );
                          },
                          onWillAcceptWithDetails: (data) => true,
                          onAcceptWithDetails: (data) => checkAnswer(bin),
                        );
                      }).toList(),
                ),
                SizedBox(height: 30),
                Text(
                  'Objeto ${currentItemIndex + 1} de ${trashItems.length}',
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
