import 'package:flutter/material.dart';

class MenuGames extends StatelessWidget {
  const MenuGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/telaFundo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 100),
            Image.asset('assets/images/logoEcoQuest.png', width: 200),
            SizedBox(height: 10),
            Text(
              "Selecione o jogo que deseja jogar",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSansPro',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 90),
            _botaoJogo(context, 'Spelling Game (Letras)', '/spelling_letters'),
            _botaoJogo(
              context,
              'Spelling Game (Sílabas)',
              '/spelling_syllables',
            ),
            _botaoJogo(context, 'Lixeira Correta', '/trash_sorting'),
            _botaoJogo(context, 'Quiz Fácil', '/quiz_easy'),
            _botaoJogo(context, 'Quiz Difícil', '/quiz_hard'),
            _botaoJogo(context, 'Lixeira Fácil', '/easy_trash_sorting'),
          ],
        ),
      ),
    );
  }

  Widget _botaoJogo(BuildContext context, String nome, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2BB462),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(nome, style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
