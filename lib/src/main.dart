import 'package:ecoquest/src/pages/games/quizhard.dart';
import 'package:ecoquest/src/pages/resetPassword.dart';
import 'package:ecoquest/src/pages/games/quizeasy.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: QuizScreenHard());
  }
}
