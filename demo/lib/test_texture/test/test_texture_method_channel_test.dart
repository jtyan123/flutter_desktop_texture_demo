import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_texture/test_texture_method_channel.dart';

void main() {
  MethodChannelTestTexture platform = MethodChannelTestTexture();
  const MethodChannel channel = MethodChannel('test_texture');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
