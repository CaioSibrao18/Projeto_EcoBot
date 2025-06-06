// Mocks generated by Mockito 5.4.6 from annotations
// in ecoquest/test/mocks/easytrash_logic_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ecoquest/pages/games/easytrash_logic.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [EasyTrashGameLogic].
///
/// See the documentation for Mockito's code generation for more information.
class MockEasyTrashGameLogic extends _i1.Mock
    implements _i2.EasyTrashGameLogic {
  MockEasyTrashGameLogic() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<Map<String, dynamic>> get trashItems =>
      (super.noSuchMethod(
            Invocation.getter(#trashItems),
            returnValue: <Map<String, dynamic>>[],
          )
          as List<Map<String, dynamic>>);

  @override
  int get currentItemIndex =>
      (super.noSuchMethod(Invocation.getter(#currentItemIndex), returnValue: 0)
          as int);

  @override
  int get correctAnswers =>
      (super.noSuchMethod(Invocation.getter(#correctAnswers), returnValue: 0)
          as int);

  @override
  set currentItemIndex(int? _currentItemIndex) => super.noSuchMethod(
    Invocation.setter(#currentItemIndex, _currentItemIndex),
    returnValueForMissingStub: null,
  );

  @override
  set correctAnswers(int? _correctAnswers) => super.noSuchMethod(
    Invocation.setter(#correctAnswers, _correctAnswers),
    returnValueForMissingStub: null,
  );

  @override
  set lastResultText(String? _lastResultText) => super.noSuchMethod(
    Invocation.setter(#lastResultText, _lastResultText),
    returnValueForMissingStub: null,
  );

  @override
  set lastResultBin(String? _lastResultBin) => super.noSuchMethod(
    Invocation.setter(#lastResultBin, _lastResultBin),
    returnValueForMissingStub: null,
  );

  @override
  set lastResultCorrect(bool? _lastResultCorrect) => super.noSuchMethod(
    Invocation.setter(#lastResultCorrect, _lastResultCorrect),
    returnValueForMissingStub: null,
  );

  @override
  void checkAnswer(String? selectedBin) => super.noSuchMethod(
    Invocation.method(#checkAnswer, [selectedBin]),
    returnValueForMissingStub: null,
  );

  @override
  void nextItem() => super.noSuchMethod(
    Invocation.method(#nextItem, []),
    returnValueForMissingStub: null,
  );

  @override
  bool isGameFinished() =>
      (super.noSuchMethod(
            Invocation.method(#isGameFinished, []),
            returnValue: false,
          )
          as bool);

  @override
  void resetGame() => super.noSuchMethod(
    Invocation.method(#resetGame, []),
    returnValueForMissingStub: null,
  );

  @override
  String getCurrentImage() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentImage, []),
            returnValue: _i3.dummyValue<String>(
              this,
              Invocation.method(#getCurrentImage, []),
            ),
          )
          as String);

  @override
  String getCorrectBinForCurrentItem() =>
      (super.noSuchMethod(
            Invocation.method(#getCorrectBinForCurrentItem, []),
            returnValue: _i3.dummyValue<String>(
              this,
              Invocation.method(#getCorrectBinForCurrentItem, []),
            ),
          )
          as String);

  @override
  int getTotalItems() =>
      (super.noSuchMethod(Invocation.method(#getTotalItems, []), returnValue: 0)
          as int);

  @override
  int getCurrentProgress() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentProgress, []),
            returnValue: 0,
          )
          as int);
}
