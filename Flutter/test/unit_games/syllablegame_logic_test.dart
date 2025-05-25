import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/games/syllablegame_logic.dart';

void main() {
  group('SyllableGameLogic Tests', () {
    late SyllableGameLogic game;

    final mockWords = [
      {'word': 'bo-la', 'syllables': ['bo', 'la']},
      {'word': 'ca-sa', 'syllables': ['ca', 'sa']},
    ];

    setUp(() {
      // Instancia o jogo e reseta o estado antes de cada teste
      game = SyllableGameLogic(words: mockWords);
      game.resetGame();
    });

    test('Inicialização correta', () {
      // Verifica se o jogo foi inicializado com os valores corretos
      expect(game.currentWordIndex, 0);
      expect(game.correctAnswers, 0);
      expect(game.selectedSyllables, isEmpty);
      expect(game.availableSyllables.length, 2);
      expect(game.incorrectWord, isNull);
    });

    test('Adicionar sílaba move da lista disponível para selecionada', () {
      // Verifica se a sílaba é movida da lista de disponíveis para selecionadas
      final syllable = game.availableSyllables.first;
      game.addSyllable(syllable);

      expect(game.selectedSyllables.contains(syllable), true);
      expect(game.availableSyllables.contains(syllable), false);
    });

    test('Verifica resposta correta', () {
      // Simula a formação correta da palavra e testa se o jogo reconhece como certa
      final correctSyllables = (mockWords[0]['word'] as String).split('-');
      for (var syllable in correctSyllables) {
        game.addSyllable(syllable);
      }

      final result = game.checkAnswer();
      expect(result, true); 
      expect(game.correctAnswers, 1); 
      expect(game.incorrectWord, isNull);
    });

    test('Verifica resposta incorreta', () {
      // Simula uma resposta errada (sílabas na ordem errada)
      game.addSyllable('la');
      game.addSyllable('bo');

      final result = game.checkAnswer();
      expect(result, false); 
      expect(game.correctAnswers, 0); 
      expect(game.incorrectWord, 'bo-la'); 
    });

    test('Avança para próxima palavra e reseta estado', () {
      // Testa se o jogo avança corretamente e reinicia os estados necessários
      game.addSyllable('bo');
      game.addSyllable('la');
      game.checkAnswer();
      game.goToNextWord();

      expect(game.currentWordIndex, 1); 
      expect(game.selectedSyllables, isEmpty); 
      expect(game.availableSyllables.length, 2); 
      expect(game.incorrectWord, isNull); 
    });

    test('Verifica se jogo está completo', () {
      // Testa se o jogo reconhece quando chegou à última palavra
      game.goToNextWord();
      expect(game.isGameComplete, true);
    });

    test('Cálculo de tempo médio', () {
      // Testa se a média dos tempos está sendo calculada corretamente
      game.wordTimes = [1000, 1500, 2000]; 
      final average = game.calculateAverageWordTime();
      expect(average, 1500); 
    });

    test('Cálculo de tempo médio vazio retorna 0', () {
      // Testa se a média retorna 0 quando a lista está vazia
      final average = game.calculateAverageWordTime();
      expect(average, 0);
    });
  });
}
