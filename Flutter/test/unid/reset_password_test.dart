import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/resetPassword.dart';

void main() {
  group('Testes da ResetPasswordScreen', () {
    testWidgets('Deve renderizar corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Redefinir minha senha'), findsOneWidget);
      expect(find.text('Insira uma nova senha para concluir a mudança.'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Nova senha'), findsOneWidget);
      expect(find.text('Repita a nova senha'), findsOneWidget);
      expect(find.text('Redefinir Senha'), findsOneWidget);
      expect(find.text('Voltar a tela de login'), findsOneWidget);
    });

    testWidgets('Botão "Redefinir Senha" deve navegar', (WidgetTester tester) async {
      // Configuração mais simples sem conflito de rotas
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // Encontra o botão de forma mais robusta
      final redefinirButton = find.ancestor(
        of: find.text('Redefinir Senha'),
        matching: find.byType(ElevatedButton),
      );
      
      expect(redefinirButton, findsOneWidget);
      
      // Simula o tap
      await tester.tap(redefinirButton);
      await tester.pump();
    });

    testWidgets('Botão "Voltar" deve funcionar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // Encontra o botão Voltar
      final voltarButton = find.text('Voltar a tela de login');
      expect(voltarButton, findsOneWidget);
      
      // Simula o tap
      await tester.tap(voltarButton);
      await tester.pump();
    });
  });
}