import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/menuGames.dart';

class MockNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRouteNames = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pushedRouteNames.add(route.settings.name!);
    }
  }
}

void main() {
  group('Testes do MenuGames', () {
    testWidgets('Deve exibir os 6 botões de jogos', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MenuGames(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Spelling Game (Letras)'), findsOneWidget);
      expect(find.text('Spelling Game (Sílabas)'), findsOneWidget);
      expect(find.text('Lixeira Correta'), findsOneWidget);
      expect(find.text('Quiz Fácil'), findsOneWidget);
      expect(find.text('Quiz Difícil'), findsOneWidget);
      expect(find.text('Lixeira Fácil'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(6));
    });

    testWidgets('Botão deve navegar para tela correta', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();
      
      await tester.pumpWidget(
        MaterialApp(
          home: const MenuGames(),
          navigatorObservers: [mockObserver],
          routes: {
            '/spelling_letters': (context) => const Scaffold(body: Center(child: Text('Tela Spelling Letters'))),
          },
        ),
      );

      await tester.pump();
      await tester.tap(find.text('Spelling Game (Letras)'));
      await tester.pumpAndSettle();

      // Verifica se a rota desejada foi a última adicionada
      expect(mockObserver.pushedRouteNames.isNotEmpty, true);
      expect(mockObserver.pushedRouteNames.last, '/spelling_letters');
      expect(find.text('Tela Spelling Letters'), findsOneWidget);
    });
  });
}