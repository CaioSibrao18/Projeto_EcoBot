import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ecoquest/pages/menuGames.dart';

@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
import 'widget_menu_games_test.mocks.dart';

void main() {
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  Future<void> pumpMenuGames(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MenuGames(),
        navigatorObservers: [mockObserver],
        routes: {
          '/spelling_letters': (context) => const Scaffold(body: Center(child: Text('Tela de Soletrar'))),
          '/login': (context) => const Scaffold(body: Center(child: Text('Tela de Login'))),
          // outras rotas que desejar testar podem ser adicionadas aqui
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Exibe o texto de boas-vindas e todos os jogos', (tester) async {
    await pumpMenuGames(tester);

    expect(find.text('Olá, seja bem vindo ao EcoQuest!'), findsOneWidget);
    expect(find.text('Escolha um jogo para começar'), findsOneWidget);

    expect(find.text('Soletrar por Letras'), findsOneWidget);
    expect(find.text('Soletrar por Sílabas'), findsOneWidget);
    expect(find.text('Coleta Fácil'), findsOneWidget);
    expect(find.text('Coleta Difícil'), findsOneWidget);
    expect(find.text('Quiz Fácil'), findsOneWidget);
    expect(find.text('Quiz Difícil'), findsOneWidget);
  });

  testWidgets('Navega para /spelling_letters ao tocar no jogo correspondente', (tester) async {
    await pumpMenuGames(tester);

    clearInteractions(mockObserver);

    await tester.tap(find.text('Soletrar por Letras'));
    await tester.pumpAndSettle();

    verify(mockObserver.didPush(any, any)).called(1);
    expect(find.text('Tela de Soletrar'), findsOneWidget);
  });

  testWidgets('Exibe diálogo de confirmação de logout e navega ao confirmar', (tester) async {
    await pumpMenuGames(tester);

    clearInteractions(mockObserver);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Sair da conta'), findsOneWidget);
    expect(find.text('Você realmente deseja sair da sua conta?'), findsOneWidget);

    // Testa cancelar - diálogo desaparece
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Sair da conta'), findsNothing);

    // Abre diálogo novamente para testar confirmar logout
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    verify(mockObserver.didPush(any, any)).called(greaterThanOrEqualTo(1));
    expect(find.text('Tela de Login'), findsOneWidget);
  });
}
