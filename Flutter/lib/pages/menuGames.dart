import 'package:flutter/material.dart';
import 'menuGames_logic.dart';

class MenuGames extends StatelessWidget {
  const MenuGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF7),
      body: Column(
        children: [
          _buildUserHeader(context),
          const SizedBox(height: 20),
          const LogoImage(),
          const SizedBox(height: 40),
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
                    _gameTile(
                      context,
                      'Soletrar por Letras',
                      'assets/images/iconpalavra.png',
                      '/spelling_letters',
                    ),
                    _gameTile(
                      context,
                      'Soletrar por Sílabas',
                      'assets/images/iconsilaba.png',
                      '/spelling_syllables',
                    ),
                    _gameTile(
                      context,
                      'Coleta Fácil',
                      'assets/images/iconcoletafacil.png',
                      '/easy_trash_sorting',
                    ),
                    _gameTile(
                      context,
                      'Coleta Difícil',
                      'assets/images/iconcoletadificil.png',
                      '/trash_sorting',
                    ),
                    _gameTile(
                      context,
                      'Quiz Fácil',
                      'assets/images/iconquizfacil.png',
                      '/quiz_easy',
                    ),
                    _gameTile(
                      context,
                      'Quiz Difícil',
                      'assets/images/iconquizdificil.png',
                      '/quiz_hard',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 50, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2BB462),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Olá, seja bem vindo ao EcoQuest!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2BB462),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () => _showLogoutConfirmation(context),
              child: const Center(
                child: Icon(Icons.logout, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Você realmente deseja sair da sua conta?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        );
      },
    );
  }

  static Widget _gameTile(
    BuildContext context,
    String title,
    String imagePath,
    String route,
  ) {
    return GestureDetector(
      onTap: () => GameNavigator.navigateTo(context, route),
      child: Container(
        width: MediaQuery.of(context).size.width / 2.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 64, height: 64, fit: BoxFit.contain),
            const SizedBox(height: 20),
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
    return const Text(
      "Escolha um jogo para começar",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontFamily: 'PressStart2P',
        shadows: [
          Shadow(blurRadius: 4, offset: Offset(1, 1), color: Colors.black12),
        ],
      ),
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logoEcoQuest.png', width: 150);
  }
}