import 'package:flutter/material.dart';

class MenuGames extends StatelessWidget {
  const MenuGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const LogoImage(),
          const SizedBox(height: 12),
          const TitleText(),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _gameTile(context, 'Soletrar por Letras', 'assets/images/iconpalavra.png', '/spelling_letters'),
                    _gameTile(context, 'Soletrar por Sílabas', 'assets/images/iconsilaba.png', '/spelling_syllables'),
                    _gameTile(context, 'Coleta Fácil', 'assets/images/iconcoletafacil.png', '/easy_trash_sorting'),
                    _gameTile(context, 'Coleta Difícil', 'assets/images/iconcoletadificil.png', '/trash_sorting'),
                    _gameTile(context, 'Quiz Fácil', 'assets/images/iconquizfacil.png', '/quiz_easy'),
                    _gameTile(context, 'Quiz Difícil', 'assets/images/iconquizdificil.png', '/quiz_hard'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gameTile(BuildContext context, String title, String imagePath, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: MediaQuery.of(context).size.width / 2.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Escolha um jogo para começar",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontFamily: 'PressStart2P',
        shadows: [
          Shadow(
            blurRadius: 4,
            offset: Offset(1, 1),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logoEcoQuest.png',
      width: 150,
    );
  }
}