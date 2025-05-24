// test/forgetPasswordScreen_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/forgetPasswordScreen_logic.dart';

void main() {
  group('Validação de e-mail', () {
    test('Retorna erro se o e-mail estiver vazio', () {
      final result = ForgetPasswordService.validateEmail('');
      expect(result, 'Insira seu e-mail');
    });

    test('Retorna erro se o e-mail for inválido', () {
      final result = ForgetPasswordService.validateEmail('usuario_invalido');
      expect(result, 'E-mail inválido');
    });

    test('Retorna null se o e-mail for válido', () {
      final result = ForgetPasswordService.validateEmail('usuario@teste.com');
      expect(result, null);
    });
  });

  group('Envio de e-mail de redefinição (integração real com backend)', () {
    test('Retorna sucesso se o e-mail for reconhecido pelo backend', () async {
      // Trocar e-mail para o que quisermos utilizar
      const email = 'neto@email.com';
      final result = await ForgetPasswordService.sendResetEmail(email);
      expect(result['success'], true);
    });

    test('Retorna erro se o e-mail não existir no backend', () async {
      const email = 'naoexiste@teste.com';
      final result = await ForgetPasswordService.sendResetEmail(email);
      expect(result['success'], false);
    });

    test('Retorna erro de conexão se o backend estiver offline', () async {
      // Desligar o servidor local para esse teste e depois ligar e testar
      final result = await ForgetPasswordService.sendResetEmail('teste@offline.com');
      expect(result['success'], false);
      expect(result['message'], contains('Erro de conexão'));
    });
  });
}

// Rodar teste com o comando: flutter test test/forgetPasswordScreen_logic_test.dart --plain-name "Retorna sucesso se o e-mail for reconhecido pelo backend"
