// test/logic/registerScreen_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/registerScreen_logic.dart';

void main() {
  group('Validação de Nome', () {
    test('Retorna erro para nome vazio', () {
      expect(RegisterValidator.validateName(''), 'Insira seu nome');
    });

    test('Aceita nome válido', () {
      expect(RegisterValidator.validateName('João'), null);
    });
  });

  group('Validação de Data de Nascimento', () {
    test('Retorna erro para data vazia', () {
      expect(RegisterValidator.validateBirthDate(''), 'Insira sua data de nascimento');
    });

    test('Aceita data válida', () {
      expect(RegisterValidator.validateBirthDate('01/01/2000'), null);
    });
  });

  group('Validação de Gênero', () {
    test('Retorna erro se não for selecionado', () {
      expect(RegisterValidator.validateGender(null), 'Selecione seu gênero');
    });

    test('Aceita gênero selecionado', () {
      expect(RegisterValidator.validateGender('Masculino'), null);
    });
  });

  group('Validação de Email', () {
    test('Retorna erro para e-mail vazio', () {
      expect(RegisterValidator.validateEmail(''), 'Insira seu email');
    });

    test('Retorna erro para e-mail inválido', () {
      expect(RegisterValidator.validateEmail('usuarioemail.com'), 'Email inválido');
    });

    test('Aceita e-mail válido', () {
      expect(RegisterValidator.validateEmail('teste@email.com'), null);
    });
  });

  group('Validação de Senha', () {
    test('Retorna erro para senha vazia', () {
      expect(RegisterValidator.validatePassword(''), 'Insira sua senha');
    });

    test('Retorna erro para senha curta', () {
      expect(RegisterValidator.validatePassword('123'), 'A senha deve ter pelo menos 6 caracteres');
    });

    test('Aceita senha válida', () {
      expect(RegisterValidator.validatePassword('123456'), null);
    });
  });

  group('Validação de Confirmação de Senha', () {
    test('Retorna erro se confirmação estiver vazia', () {
      expect(RegisterValidator.validateConfirmPassword('123456', ''), 'Confirme sua senha');
    });

    test('Retorna erro se as senhas não coincidirem', () {
      expect(RegisterValidator.validateConfirmPassword('123456', '654321'), 'As senhas não coincidem');
    });

    test('Aceita se as senhas forem iguais', () {
      expect(RegisterValidator.validateConfirmPassword('123456', '123456'), null);
    });
  });
}
