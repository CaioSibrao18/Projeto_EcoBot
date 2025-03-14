import 'app_telalogin.dart';
import 'package:flutter/material.dart';
import 'package:ecoquest/pages/games/wordgame.dart';
import 'package:ecoquest/pages/games/syllablegame.dart';
import 'package:ecoquest/pages/games/hardtrash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TrashSortingGame());
  }
}
