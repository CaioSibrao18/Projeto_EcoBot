import 'package:flutter/material.dart';
import 'pages/chooseGame.dart';

void main() {
  runApp(JogoSilabasApp());
}

class JogoSilabasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaInicial(),
    );
  }
}
