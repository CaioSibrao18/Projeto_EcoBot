import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/menuGames_logic.dart';

void main() {
  final routesToTest = [
    '/quiz_easy',
    '/quiz_hard',
    '/easytrash',
    '/hardtrash',
    '/word_game',
    '/syllable_game',
  ];

  for (var route in routesToTest) {
    testWidgets('GameNavigator.navigateTo deve navegar para $route', (WidgetTester tester) async {
      final testKey = GlobalKey<NavigatorState>();
      String? pushedRoute;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: testKey,
          onGenerateRoute: (settings) {
            pushedRoute = settings.name;
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Next Page')),
              settings: settings,
            );
          },
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GameNavigator.navigateTo(context, route);
              },
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(pushedRoute, route);
    });
  }
}
