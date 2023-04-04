import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'test_texture_platform_interface.dart';

/// An implementation of [TestTexturePlatform] that uses method channels.
class MethodChannelTestTexture extends TestTexturePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('test_texture');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }


  @override
  Future<int> createLocalRender() async{
    return await methodChannel.invokeMethod('createTextureRender');
  }

  @override
  Future<void> disposeLocalRender(int textureId) async{
    await methodChannel.invokeMethod('destroyTextureRender', textureId);
  }
}
