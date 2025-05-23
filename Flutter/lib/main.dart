import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:ecoquest/pages/loginScreen.dart';
import 'package:ecoquest/pages/resetPassword.dart';
import 'package:ecoquest/pages/forgetPasswordScreen.dart';
import 'package:ecoquest/pages/registerScreen.dart';
import 'package:ecoquest/pages/menuGames.dart';

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

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/menu_games': (context) => const MenuGames(),
        '/forget_password': (context) => const ForgetPasswordScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(email: ''),
        '/register': (context) => const RegisterScreen(),
        '/spelling_letters': (context) => const SpellingGameLetters(),
        '/spelling_syllables': (context) => const SpellingGameSyllables(),
        '/easy_trash_sorting': (context) => const EasyTrashSortingGame(),
        '/trash_sorting': (context) => const TrashSortingGame(),
        '/quiz_easy': (context) => const QuizScreenEasy(),
        '/quiz_hard': (context) => const QuizScreenHard(),
      },
    );
  }
}
