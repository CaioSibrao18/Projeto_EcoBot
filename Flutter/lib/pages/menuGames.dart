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
            SizedBox(height: 50),
            Image.asset('assets/images/logoEcoQuest.png', width: 150),
            SizedBox(height: 50),
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
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: [
                  _botaoJogo(context, 'Spelling Game (Letras)', '/spelling_letters', 'btn_letras'),
                  _botaoJogo(context, 'Spelling Game (Sílabas)', '/spelling_syllables', 'btn_silabas'),
                  _botaoJogo(context, 'Lixeira Correta', '/trash_sorting', 'btn_lixeira_correta'),
                  _botaoJogo(context, 'Quiz Fácil', '/quiz_easy', 'btn_quiz_facil'),
                  _botaoJogo(context, 'Quiz Difícil', '/quiz_hard', 'btn_quiz_dificil'),
                  _botaoJogo(context, 'Lixeira Fácil', '/easy_trash_sorting', 'btn_lixeira_facil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoJogo(BuildContext context, String nome, String route, String keyName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        key: Key(keyName),
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2BB462),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(nome, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
