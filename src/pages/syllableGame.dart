import 'package:flutter/material.dart';
import '../models/baseGame.dart';

class JogoSilabas extends JogoBase{
  @override
  _JogoSilabasState createState() => _JogoSilabasState();
}

class _JogoSilabasState extends _JogoBaseState {
  @override
  void initState() {
    palavras = [
      {
        "palavra": "reciclar",
        "elementos": ["re", "ci", "clar"],
      },
      {
        "palavra": "planeta",
        "elementos": ["pla", "ne", "ta"],
      },
    ];
    super.initState();
  }

  @override
  String getTitulo() => "Jogo de Sílabas";
}
