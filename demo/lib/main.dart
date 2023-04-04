import 'package:demo/test_texture/lib/test_texture_platform_interface.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isShow = false;
  int? _textureId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            isShow && _textureId != null
                ? SizedBox(
              height: 200,
              width: 200,
              child: Texture(
                textureId: _textureId!,
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> createLocalRender() async {
    _textureId = await TestTexturePlatform.instance.createLocalRender();
    print('');
  }

  Future<void> disposeLocalRender() async {
    if (_textureId != null) {
      await TestTexturePlatform.instance.disposeLocalRender(_textureId!);
    }
  }
}

