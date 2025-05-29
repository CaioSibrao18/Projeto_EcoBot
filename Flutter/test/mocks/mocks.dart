// test/mocks.dart
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:ecoquest/pages/games/easytrash_logic.dart';

// Gerar mocks para EasyTrashGameLogic e http.Client
@GenerateMocks([EasyTrashGameLogic, http.Client])
void main() {} // Este main é apenas para o build_runner