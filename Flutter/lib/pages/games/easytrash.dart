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
      builder: (context) => AlertDialog(
        title: Text('Resposta Errada'),
        content: Text(
          'A lixeira correta era a ${correctBin.toUpperCase()}!',
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
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void showResult() {
    double percentage = (correctAnswers / trashItems.length) * 100;
    _enviarParaBackend(percentage); // Envia a porcentagem para o backend

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fim do Jogo'),
        content: Text(
          'Você acertou ${percentage.toStringAsFixed(1)}% dos objetos!',
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
            child: Text('Jogar Novamente'),
          ),
        ],
      ),
    );
  }

  // Função para enviar a porcentagem para o backend
  Future<void> _enviarParaBackend(double porcentagem) async {
    final url = Uri.parse('http://localhost:5000/saveResult');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario_id': 123,
        'porcentagem_acerto': porcentagem,
      }),
    );

    if (response.statusCode == 200) {
      print('Dados enviados com sucesso!');
    } else {
      print('Erro ao enviar: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentObject = trashItems[currentItemIndex]['name'];

    return Scaffold(
      appBar: AppBar(title: Text('Jogo da Separação do Lixo - Fácil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selecione a lixeira correta para:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Draggable<String>(
              data: currentObject,
              feedback: Material(
                child: Chip(
                  label: Text(currentObject, style: TextStyle(fontSize: 18)),
                ),
              ),
              child: Chip(
                label: Text(currentObject, style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 40),
            Wrap(
              spacing: 10,
              children: binColors.keys.map((bin) {
                return DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: binColors[bin],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        bin.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  onAcceptWithDetails: (data) => checkAnswer(bin),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
