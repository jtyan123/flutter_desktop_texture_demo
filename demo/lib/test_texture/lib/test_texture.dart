
import 'test_texture_platform_interface.dart';

class TestTexture {
  Future<String?> getPlatformVersion() {
    return TestTexturePlatform.instance.getPlatformVersion();
  }
}
