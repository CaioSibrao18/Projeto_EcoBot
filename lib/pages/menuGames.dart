import 'package:flutter/material.dart';

class menuGames extends StatelessWidget {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logoEcoQuest.png', width: 200),
            SizedBox(height: 20),

            Text(
              "Selecione o jogo que desejar jogar",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 50,
              runSpacing: 20,
              children: [
                _botaoJogo(context, 'assets/images/Trash.png', '/pixel_trash'),
                _botaoJogo(context, 'assets/images/Click.png', '/garrafa_pet'),
                _botaoJogo(
                  context,
                  'assets/images/Puzzle.png',
                  '/puzzle_palavra',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoJogo(BuildContext context, String imagePath, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Image.asset(imagePath, width: 80),
    );
  }
}
