import 'package:flutter/material.dart';

class MenuGames extends StatelessWidget {
  const MenuGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      body: Stack(
        children: [
          ClipPath(
            clipper: MenuWaveClipper(),
            child: Container(
              height: 220,
              color: const Color(0xFF2BB462),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/logoEcoQuest.png',
                  width: 140,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Escolha um jogo para começar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _gameCard(context, 'Soletrar por Letras', '/spelling_letters'),
                      _gameCard(context, 'Soletrar por Sílabas', '/spelling_syllables'),
                      _gameCard(context, 'Coleta Seletiva (Fácil)', '/easy_trash_sorting'),
                      _gameCard(context, 'Coleta Seletiva (Difícil)', '/trash_sorting'),
                      _gameCard(context, 'Quiz sobre Sustentabilidade (Fácil)', '/quiz_easy'),
                      _gameCard(context, 'Quiz sobre Sustentabilidade (Difícil)', '/quiz_hard'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameCard(BuildContext context, String title, String route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.play_arrow, color: Color(0xFF2BB462)),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

class MenuWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}