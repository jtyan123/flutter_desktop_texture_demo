import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MultiChannel Example
class RenderLocalVideo extends StatefulWidget {
  /// Construct the [RenderLocalVideo]
  const RenderLocalVideo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RenderLocalVideo> {
  late final RtcEngine _engine;
  bool _isReadyPreview = false;
  bool isJoined = false, switchCamera = true, switchRender = true;
  bool isShow = false;
  static const MethodChannel _methodChannel =
      MethodChannel('agora_rtc_ng/video_view_controller');
  int? _textureId;

  @override
  void initState() {
    super.initState();

    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.stopPreview();
    await _engine.release();
  }

  Future<void> _initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: '57426acbe76642c999f1a9206b097cde'));
    await _engine.enableVideo();
    await _engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0,
      ),
    );
    await _engine.startPreview();
    setState(() {
      _isReadyPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rendered by Flutter texture: '),
              Switch(
                value: isShow,
                onChanged: (changed) async {
                  isShow = !isShow;
                  if (isShow) {
                    await createLocalRender();
                  } else {
                    await disposeLocalRender();
                  }
                  setState(() {});
                },
              )
            ]),
         const SizedBox(
          width: 20,
        ),
        _isReadyPreview && isShow && _textureId != null
            ? SizedBox(
                height: 200,
                width: 200,
                child: Texture(
                  textureId: _textureId!,
                ),
              )
            : Container(),
      ],
    );
  }

  Future<void> createLocalRender() async {
    if (_textureId != null) {
      await disposeLocalRender();
    }
    _textureId = await _methodChannel.invokeMethod('createTextureRender', {
      'videoFrameBufferManagerNativeHandle':
          _engine.getVideoFrameBufferManager(),
      'uid': 0,
      'channelId': '',
      'videoSourceType': 0,
    });
  }

  Future<void> disposeLocalRender() async {
    if (_textureId != null) {
      await _methodChannel.invokeMethod('destroyTextureRender', _textureId);
    }
  }
}
