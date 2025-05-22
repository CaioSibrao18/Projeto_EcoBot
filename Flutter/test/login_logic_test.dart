// test/logic/login_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/login_logic.dart';

void main() {
  group('Validação de E-mail', () {
    test('Retorna erro para e-mail vazio', () {
      expect(LoginValidator.validateEmail(''), 'Insira seu email');
    });

    test('Retorna erro para e-mail inválido', () {
      expect(LoginValidator.validateEmail('usuarioemail.com'), 'Email inválido');
    });

    test('Aceita e-mail válido', () {
      expect(LoginValidator.validateEmail('teste@email.com'), null);
    });
  });

  group('Validação de Senha', () {
    test('Retorna erro para senha vazia', () {
      expect(LoginValidator.validatePassword(''), 'Insira sua senha');
    });

    test('Retorna erro para senha curta', () {
      expect(LoginValidator.validatePassword('123'), 'A senha deve ter pelo menos 6 caracteres');
    });

    test('Aceita senha válida', () {
      expect(LoginValidator.validatePassword('123456'), null);
    });
  });
}
