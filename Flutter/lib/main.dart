// ignore_for_file: duplicate_import, unused_import

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
      initialRoute: '/app_telalogin',
      routes: {
        '/': (context) => EasyTrashSortingGame(), // Página inicial
      },
    );
  }
}
