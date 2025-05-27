import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // Importe para EditableText
import 'package:http/http.dart' as http;

import 'package:ecoquest/pages/resetPassword_logic.dart';
import 'package:ecoquest/pages/resetPassword.dart';

import 'widget_reset_password_test.mocks.dart';

@GenerateMocks([ResetPasswordService])
void main() {
  late MockResetPasswordService mockResetPasswordService;

  setUp(() {
    mockResetPasswordService = MockResetPasswordService();
  });

  testWidgets('ResetPasswordScreen displays all required fields and pre-fills email', (WidgetTester tester) async {
    const String testEmail = 'test@example.com';

    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(email: testEmail),
      ),
    );

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Token de verificação'), findsOneWidget);
    expect(find.text('Nova senha (mínimo 6 caracteres)'), findsOneWidget);
    expect(find.text('Confirmar nova senha'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, testEmail), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Redefinir Senha'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Voltar'), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen shows validation errors for empty fields', (WidgetTester tester) async {
    const String testEmail = 'test@example.com';

    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(email: testEmail),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Redefinir Senha'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsNWidgets(3));
    expect(find.text('Mínimo 6 caracteres'), findsNothing);
  });

  testWidgets('ResetPasswordScreen shows error when passwords do not match', (WidgetTester tester) async {
    const String testEmail = 'test@example.com';

    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(email: testEmail),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Token de verificação'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nova senha (mínimo 6 caracteres)'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar nova senha'), 'password456');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Redefinir Senha'));
    await tester.pump();

    expect(find.text('As senhas não coincidem'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Password visibility toggles correctly for new password field', (WidgetTester tester) async {
    const String testEmail = 'test@example.com';
    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(email: testEmail),
      ),
    );

    final newPasswordFieldFinder = find.widgetWithText(TextFormField, 'Nova senha (mínimo 6 caracteres)');
    expect(newPasswordFieldFinder, findsOneWidget);

    EditableText newPasswordEditableText = tester.widget<EditableText>(
      find.descendant(
        of: newPasswordFieldFinder,
        matching: find.byType(EditableText),
      ),
    );
    expect(newPasswordEditableText.obscureText, isTrue);

    final newPasswordToggle = find.descendant(
      of: newPasswordFieldFinder,
      matching: find.byIcon(Icons.visibility),
    );
    expect(newPasswordToggle, findsOneWidget);

    await tester.tap(newPasswordToggle);
    await tester.pump();

    final newPasswordToggleOff = find.descendant(
      of: newPasswordFieldFinder,
      matching: find.byIcon(Icons.visibility_off),
    );
    expect(newPasswordToggleOff, findsOneWidget);

    newPasswordEditableText = tester.widget<EditableText>(
      find.descendant(
        of: newPasswordFieldFinder,
        matching: find.byType(EditableText),
      ),
    );
    expect(newPasswordEditableText.obscureText, isFalse);
  });

  testWidgets('New password validation for length displays correctly', (WidgetTester tester) async {
    const String testEmail = 'test@example.com';
    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(email: testEmail),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Nova senha (mínimo 6 caracteres)'), 'abc');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar nova senha'), 'abc');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Redefinir Senha'));
    await tester.pump();

    // Procura a mensagem "Mínimo 6 caracteres" que é descendente do campo 'Nova senha'
    expect(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Nova senha (mínimo 6 caracteres)'),
        matching: find.text('Mínimo 6 caracteres'),
      ),
      findsOneWidget,
    );
    // Assegura que a mesma mensagem também aparece para o campo 'Confirmar nova senha' (se for o caso)
    expect(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Confirmar nova senha'),
        matching: find.text('Mínimo 6 caracteres'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Required field validation for token', (WidgetTester tester) async {
    const String testEmail = 'test@example.com';
    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(email: testEmail),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Nova senha (mínimo 6 caracteres)'), 'abcdef');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar nova senha'), 'abcdef');
    await tester.enterText(find.widgetWithText(TextFormField, 'Token de verificação'), '');


    await tester.tap(find.widgetWithText(ElevatedButton, 'Redefinir Senha'));
    await tester.pump();

    expect(find.descendant(of: find.widgetWithText(TextFormField, 'Token de verificação'), matching: find.text('Campo obrigatório')), findsOneWidget);
    expect(find.descendant(of: find.widgetWithText(TextFormField, 'Nova senha (mínimo 6 caracteres)'), matching: find.text('Campo obrigatório')), findsNothing);
    expect(find.descendant(of: find.widgetWithText(TextFormField, 'Confirmar nova senha'), matching: find.text('Campo obrigatório')), findsNothing);
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}