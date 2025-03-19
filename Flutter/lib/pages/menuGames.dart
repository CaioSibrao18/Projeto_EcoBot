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
        child: Stack(
          children: [
            // Logo
            Positioned(
              top: 85,
              left: MediaQuery.of(context).size.width / 2 - 100, // Centralizado
              child: Image.asset('assets/images/logoEcoQuest.png', width: 200),
            ),

            // Texto de instrução
            Positioned(
              top: 280,
              left: MediaQuery.of(context).size.width / 2 - 147, // Centralizado
              child: SizedBox(
                width: 300,
                child: Text(
                  "Selecione o jogo que desejar jogar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSansPro',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Linha com os dois primeiros ícones
            Positioned(
              top: 355, // Ajuste a altura da linha
              left:
                  MediaQuery.of(context).size.width / 2 -
                  105, // Centraliza a linha
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _botaoJogo(
                    context,
                    'assets/images/Trash.png',
                    '/pixel_trash',
                  ),
                  SizedBox(width: 35), // Espaço entre os ícones
                  _botaoJogo(
                    context,
                    'assets/images/Click.png',
                    '/garrafa_pet',
                  ),
                ],
              ),
            ),

            // Ícone Puzzle Palavra (abaixo da linha)
            Positioned(
              width: 110,
              height: 110,
              top: 453, // Ajuste a posição vertical
              left: MediaQuery.of(context).size.width / 2 - 45, // Centralizado
              child: _botaoJogo(
                context,
                'assets/images/Puzzle.png',
                '/puzzle_palavra',
              ),
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
      child: Image.asset(imagePath, width: 90),
    );
  }
}
