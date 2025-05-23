import 'package:flutter_test/flutter_test.dart';
import 'package:ecoquest/pages/resetPassword_logic.dart';

void main() {
  test('Senhas devem coincidir', () {
    expect(ResetPasswordService.passwordsMatch('abc123', 'abc123'), true);
    expect(ResetPasswordService.passwordsMatch('abc123', 'xyz789'), false);
  });

  test('Validação de senha', () {
    expect(ResetPasswordService.validatePassword(''), 'Campo obrigatório');
    expect(ResetPasswordService.validatePassword('123'), 'Mínimo 6 caracteres');
    expect(ResetPasswordService.validatePassword('abcdef'), null);
  });

  test('Validação de campo obrigatório', () {
    expect(ResetPasswordService.validateRequiredField(''), 'Campo obrigatório');
    expect(ResetPasswordService.validateRequiredField('algum texto'), null);
  });
}
