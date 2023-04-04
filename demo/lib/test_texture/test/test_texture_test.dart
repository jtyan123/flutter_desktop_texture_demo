import 'package:flutter_test/flutter_test.dart';
import 'package:test_texture/test_texture.dart';
import 'package:test_texture/test_texture_platform_interface.dart';
import 'package:test_texture/test_texture_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTestTexturePlatform
    with MockPlatformInterfaceMixin
    implements TestTexturePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TestTexturePlatform initialPlatform = TestTexturePlatform.instance;

  test('$MethodChannelTestTexture is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTestTexture>());
  });

  test('getPlatformVersion', () async {
    TestTexture testTexturePlugin = TestTexture();
    MockTestTexturePlatform fakePlatform = MockTestTexturePlatform();
    TestTexturePlatform.instance = fakePlatform;

    expect(await testTexturePlugin.getPlatformVersion(), '42');
  });
}
