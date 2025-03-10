import 'package:flutter/material.dart';
import '../models/baseGame.dart';

class JogoLetras extends JogoBase {
  @override
  _JogoLetrasState createState() => _JogoLetrasState();
}

class _JogoLetrasState extends _JogoBaseState {
  @override
  void initState() {
    palavras = [
      {
        "palavra": "eco",
        "elementos": ["e", "c", "o"],
      },
      {
        "palavra": "sol",
        "elementos": ["s", "o", "l"],
      },
    ];
    super.initState();
  }

  @override
  String getTitulo() => "Jogo de Letras";
}