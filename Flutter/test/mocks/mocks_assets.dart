import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupMockAssets() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('flutter/assets'),
          (MethodCall methodCall) async {
        return Uint8List(0);
      });
}