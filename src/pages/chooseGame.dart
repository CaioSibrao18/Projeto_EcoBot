// lib/pages/tela_inicial.dart
import 'package:flutter/material.dart';
import 'syllableGame.dart';
import 'wordGame.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coletânea de Jogos")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JogoSilabas()),
                );
              },
              child: const Text("Jogo de Sílabas"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JogoLetras()),
                );
              },
              child: const Text("Jogo de Letras"),
            ),
          ],
        ),
      ),
    );
  }
}