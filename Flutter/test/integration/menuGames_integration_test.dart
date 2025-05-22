import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock do MenuGames só com botões texto
class MenuGamesMock extends StatelessWidget {
  const MenuGamesMock({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonLabelsToRoutes = {
      'Soletrar por Letras': '/spelling_letters',
      'Soletrar por Sílabas': '/spelling_syllables',
      'Coleta Fácil': '/easy_trash_sorting',
      'Coleta Difícil': '/trash_sorting',
      'Quiz Fácil': '/quiz_easy',
      'Quiz Difícil': '/quiz_hard',
    };

    return Scaffold(
      body: ListView(
        children: buttonLabelsToRoutes.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton(
              key: Key(entry.key), // Chave para facilitar o find
              onPressed: () => Navigator.pushNamed(context, entry.value),
              child: Text(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Widget helper para as rotas de destino, com AppBar e texto
class RouteScreen extends StatelessWidget {
  final String title;
  const RouteScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(child: Text(title)),
    );
  }
}

void main() {
  testWidgets('Cada botão do menu deve navegar para a rota correta', (tester) async {
    final routes = <String, WidgetBuilder>{
      '/spelling_letters': (_) => const RouteScreen('Soletrar por Letras'),
      '/spelling_syllables': (_) => const RouteScreen('Soletrar por Sílabas'),
      '/easy_trash_sorting': (_) => const RouteScreen('Coleta Fácil'),
      '/trash_sorting': (_) => const RouteScreen('Coleta Difícil'),
      '/quiz_easy': (_) => const RouteScreen('Quiz Fácil'),
      '/quiz_hard': (_) => const RouteScreen('Quiz Difícil'),
    };

    final buttonLabelsToRoutes = {
      'Soletrar por Letras': '/spelling_letters',
      'Soletrar por Sílabas': '/spelling_syllables',
      'Coleta Fácil': '/easy_trash_sorting',
      'Coleta Difícil': '/trash_sorting',
      'Quiz Fácil': '/quiz_easy',
      'Quiz Difícil': '/quiz_hard',
    };

    await tester.pumpWidget(MaterialApp(
      routes: routes,
      home: const MenuGamesMock(),
    ));

    for (final entry in buttonLabelsToRoutes.entries) {
      final buttonFinder = find.byKey(Key(entry.key));
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verifica se a tela com o texto esperado está aberta
      expect(find.text(entry.key), findsWidgets);

      // Volta para a tela do menu
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
