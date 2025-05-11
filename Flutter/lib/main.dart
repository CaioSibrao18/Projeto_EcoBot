import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:ecoquest/pages/loginScreen.dart';
import 'package:ecoquest/pages/resetPassword.dart';
import 'package:ecoquest/pages/forgetPasswordScreen.dart';
import 'package:ecoquest/pages/registerScreen.dart';

import 'pages/menuGames.dart';

import 'package:ecoquest/pages/games/wordgame.dart';
import 'package:ecoquest/pages/games/syllablegame.dart';
import 'package:ecoquest/pages/games/hardtrash.dart';
import 'package:ecoquest/pages/games/quizhard.dart';
import 'package:ecoquest/pages/games/quizeasy.dart';
import 'package:ecoquest/pages/games/easytrash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
   
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],

      initialRoute: '/app_telalogin',
      routes: {
        '/': (context) => const LoginScreen(),
        '/menu_games': (context) => MenuGames(),
        '/forget_password': (context) => ForgetPasswordScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/spelling_letters': (context) => SpellingGameLetters(),
        '/spelling_syllables': (context) => SpellingGameSyllables(),
        '/trash_sorting': (context) => TrashSortingGame(),
        '/quiz_easy': (context) => QuizScreenEasy(),
        '/quiz_hard': (context) => QuizScreenHard(),
        '/easy_trash_sorting': (context) => EasyTrashSortingGame(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
