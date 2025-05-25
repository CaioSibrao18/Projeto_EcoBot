
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/easytrash_logic.dart';

void main() {
  group('EasyTrashGameLogic', () {
    late EasyTrashGameLogic gameLogic;

    // Lista de itens para o teste simulado
    final sampleTrashItems = [
      {'image': 'banana.png', 'correctBin': 'orgânico'},
      {'image': 'garrafa.png', 'correctBin': 'plástico'},
      {'image': 'papelão.png', 'correctBin': 'papel'},
    ];

    // Executa antes de cada teste individual
    setUp(() {
      gameLogic = EasyTrashGameLogic(trashItems: sampleTrashItems);
    });

    // Testa se o jogo inicia corretamente com os valores padrão
    test('Deve iniciar com o índice e respostas corretos zerados', () {
      expect(gameLogic.currentItemIndex, 0); 
      expect(gameLogic.correctAnswers, 0); 
      expect(gameLogic.lastResultText, isNull); 
      expect(gameLogic.lastResultBin, isNull);
      expect(gameLogic.lastResultCorrect, isNull);
    });

    // Testa se a imagem e a lixeira correta do item atual são retornadas corretamente
    test('Deve retornar a imagem e lixeira correta do item atual', () {
      expect(gameLogic.getCurrentImage(), 'banana.png'); 
      expect(gameLogic.getCorrectBinForCurrentItem(), 'orgânico'); 
    });

    // Testa se a resposta correta aumenta o contador de acertos
    test('Deve verificar resposta correta e atualizar contador', () {
      gameLogic.checkAnswer('orgânico'); 
      expect(gameLogic.lastResultCorrect, isTrue); 
      expect(gameLogic.correctAnswers, 1); 
    });

    // Testa se a resposta errada não aumenta o contador de acertos
    test('Deve verificar resposta incorreta e manter contador', () {
      gameLogic.checkAnswer('papel'); 
      expect(gameLogic.lastResultCorrect, isFalse); 
      expect(gameLogic.correctAnswers, 0); 
    });

    // Testa se o jogo avança corretamente para o próximo item
    test('Deve avançar para o próximo item', () {
      gameLogic.nextItem(); 
      expect(gameLogic.currentItemIndex, 1); 
      expect(gameLogic.getCurrentImage(), 'garrafa.png'); 
      expect(gameLogic.lastResultText, isNull); 
    });

    // Testa se o jogo reconhece que chegou ao final
    test('Deve identificar quando o jogo termina', () {
      gameLogic.nextItem();
      gameLogic.nextItem(); 
      expect(gameLogic.isGameFinished(), isTrue); 
    });

    // Testa se o método de reiniciar reseta todos os valores corretamente
    test('Deve reiniciar o jogo corretamente', () {
      gameLogic.checkAnswer('orgânico');
      gameLogic.nextItem(); 
      gameLogic.resetGame(); 

      expect(gameLogic.currentItemIndex, 0); 
      expect(gameLogic.correctAnswers, 0); 
      expect(gameLogic.lastResultText, isNull);
      expect(gameLogic.lastResultBin, isNull);
      expect(gameLogic.lastResultCorrect, isNull);
    });

    // Testa se o progresso atual é retornado corretamente
    test('Deve retornar o progresso corretamente', () {
      expect(gameLogic.getCurrentProgress(), 1); 
      gameLogic.nextItem(); 
      expect(gameLogic.getCurrentProgress(), 2); 
    });

    // Testa se o total de itens é retornado corretamente
    test('Deve retornar o número total de itens', () {
      expect(gameLogic.getTotalItems(), 3); 
    });
  });
}
