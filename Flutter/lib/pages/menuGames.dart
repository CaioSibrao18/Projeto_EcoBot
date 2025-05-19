import 'package:flutter/material.dart';

class MenuGames extends StatelessWidget {
  const MenuGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      body: Stack(
        children: [
          const WaveHeader(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const LogoImage(),
                const SizedBox(height: 60),
                const TitleText(),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        _gameButton(context, 'Soletrar por Letras', '/spelling_letters'),
                        _gameButton(context, 'Soletrar por Sílabas', '/spelling_syllables'),
                        _gameButton(context, 'Coleta Seletiva (Fácil)', '/easy_trash_sorting'),
                        _gameButton(context, 'Coleta Seletiva (Difícil)', '/trash_sorting'),
                        _gameButton(context, 'Quiz sobre Sustentabilidade (Fácil)', '/quiz_easy'),
                        _gameButton(context, 'Quiz sobre Sustentabilidade (Difícil)', '/quiz_hard'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gameButton(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2BB462),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          elevation: 4,
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.play_arrow, size: 26, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class WaveHeader extends StatelessWidget {
  const WaveHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 240,
        color: const Color(0xFF2BB462),
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
        fontSize: 18,
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
      width: 180,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 80, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}