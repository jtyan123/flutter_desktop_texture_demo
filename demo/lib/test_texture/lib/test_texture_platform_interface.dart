

import 'test_texture_method_channel.dart';

abstract class TestTexturePlatform{
  /// Constructs a TestTexturePlatform.
  TestTexturePlatform();

  static TestTexturePlatform _instance = MethodChannelTestTexture();

  /// The default instance of [TestTexturePlatform] to use.
  ///
  /// Defaults to [MethodChannelTestTexture].
  static TestTexturePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TestTexturePlatform] when
  /// they register themselves.
  static set instance(TestTexturePlatform instance) {
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> createLocalRender() {
    throw UnimplementedError('createLocalRender');
  }

  Future<void> disposeLocalRender(int textureId) {
    throw UnimplementedError('disposeLocalRender');
  }
}
