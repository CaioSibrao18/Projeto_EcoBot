import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/forgetPasswordScreen.dart';

class MockNavigatorObserver extends NavigatorObserver {
  bool didPopCalled = false;

  @override
  void didPop(Route route, Route? previousRoute) {
    didPopCalled = true;
    super.didPop(route, previousRoute);
  }
}

void main() {
  // ... [outros testes aqui]

  testWidgets('Clica em "Voltar a tela de login" e volta no Navigator', (WidgetTester tester) async {
    final observer = MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: ForgetPasswordScreen(),
        navigatorObservers: [observer],
      ),
    );

    await tester.tap(find.text('Voltar a tela de login'));
    await tester.pumpAndSettle();

    // Verifica se houve navegação de volta
    expect(observer.didPopCalled, isTrue);
  });
}
