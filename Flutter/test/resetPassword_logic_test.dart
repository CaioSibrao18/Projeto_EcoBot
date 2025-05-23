import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ecoquest/pages/resetPassword_logic.dart';

// Mock da classe http.Client para simular respostas HTTP
class MockClient extends Mock implements http.Client {}

void main() {
  group('ResetPasswordLogic validations', () {
    test('validateNotEmpty returns error when value is empty or null', () {
      expect(ResetPasswordLogic.validateNotEmpty(null), 'Campo obrigatório');
      expect(ResetPasswordLogic.validateNotEmpty(''), 'Campo obrigatório');
      expect(ResetPasswordLogic.validateNotEmpty('algo'), null);
    });

    test('validatePassword returns error for invalid passwords', () {
      expect(ResetPasswordLogic.validatePassword(null), 'Campo obrigatório');
      expect(ResetPasswordLogic.validatePassword(''), 'Campo obrigatório');
      expect(ResetPasswordLogic.validatePassword('123'), 'Mínimo 6 caracteres');
      expect(ResetPasswordLogic.validatePassword('123456'), null);
    });

    test('validatePasswordsMatch returns error if passwords differ', () {
      expect(
        ResetPasswordLogic.validatePasswordsMatch('abc', 'def'),
        'As senhas não coincidem',
      );
      expect(
        ResetPasswordLogic.validatePasswordsMatch('abc123', 'abc123'),
        null,
      );
    });
  });

  group('ResetPasswordLogic resetPassword HTTP', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
    });

    test('returns success when status code is 200', () async {
      final successResponse = json.encode({'message': 'Senha alterada com sucesso!'});

      // Mockar chamada http.post para retornar sucesso
      when(client.post(
        Uri.parse('http://localhost:5000/reset-password'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(successResponse, 200));

      // Substituir http.Client da função resetPassword para usar mock
      final result = await ResetPasswordLogic.resetPassword(
        email: 'email@test.com',
        token: 'token123',
        newPassword: 'abcdef',
      );

      expect(result.success, true);
      expect(result.message, 'Senha alterada com sucesso!');
    });

    test('returns error when status code is not 200', () async {
      final errorResponse = json.encode({'error': 'Token inválido'});

      when(client.post(
        Uri.parse('http://localhost:5000/reset-password'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(errorResponse, 400));

      final result = await ResetPasswordLogic.resetPassword(
        email: 'email@test.com',
        token: 'token123',
        newPassword: 'abcdef',
      );

      expect(result.success, false);
      expect(result.message, 'Token inválido');
    });

    test('returns error on exception', () async {
      when(client.post(
        Uri.parse('http://localhost:5000/reset-password'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Falha na conexão'));

      final result = await ResetPasswordLogic.resetPassword(
        email: 'email@test.com',
        token: 'token123',
        newPassword: 'abcdef',
      );

      expect(result.success, false);
      expect(result.message, contains('Erro:'));
    });
  });
}
