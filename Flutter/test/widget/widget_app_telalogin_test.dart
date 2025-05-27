import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ecoquest/services/api_service.dart';
import 'package:ecoquest/pages/app_telalogin.dart';

import '../mocks/mock_api_service.mocks.dart';

void main() {
  late MockIApiService mockApiService;

  setUp(() {
    mockApiService = MockIApiService();
  });

  testWidgets('deve mostrar mensagem após enviar resultado com sucesso', (WidgetTester tester) async {
    // Arrange
    when(mockApiService.enviarResultado(
      usuarioId: anyNamed('usuarioId'),
      acertos: anyNamed('acertos'),
      tempoSegundos: anyNamed('tempoSegundos'),
    )).thenAnswer((_) async => 'Login realizado com sucesso');

    await tester.pumpWidget(
      MaterialApp(
        home: AppTelalogin(apiService: mockApiService),
      ),
    );

    // Act
    await tester.enterText(find.byKey(const Key('usuarioField')), '123');
    await tester.tap(find.byKey(const Key('enviarButton')));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Login realizado com sucesso'), findsOneWidget);
  });
}
