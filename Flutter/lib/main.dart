import 'package:ecoquest/pages/loginScreen.dart';
import 'package:ecoquest/pages/resetPassword.dart';
import 'package:flutter/material.dart';

import 'package:ecoquest/pages/forgetPasswordScreen.dart';
import 'pages/app_telalogin.dart';
import 'pages/menuGames.dart';

import 'package:ecoquest/pages/games/wordgame.dart';
import 'package:ecoquest/pages/games/syllablegame.dart';
import 'package:ecoquest/pages/games/hardtrash.dart';
import 'package:ecoquest/pages/games/quizeasy.dart';
import 'package:ecoquest/pages/games/quizhard.dart';
import 'package:ecoquest/pages/games/easytrash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/app_telalogin', // Definindo a tela inicial
      routes: {
        '/': (context) => LoginScreen(),
        '/menu_games': (context) => MenuGames(),
        '/forget_password': (context) => ForgetPasswordScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/spelling_letters': (context) => SpellingGameLetters(),
        '/spelling_syllables': (context) => SpellingGameSyllables(),
        '/trash_sorting': (context) => TrashSortingGame(),
        '/quiz_easy': (context) => QuizScreenEasy(),
        '/quiz_hard': (context) => QuizScreenHard(),
        '/easy_trash_sorting': (context) => EasyTrashSortingGame(),
      },
    );
  }
}