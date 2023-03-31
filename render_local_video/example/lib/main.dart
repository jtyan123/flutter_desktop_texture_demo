import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'render_local_video.dart';
void main() => runApp(const MyApp());

/// This widget is the root of your application.
class MyApp extends StatefulWidget {
  /// Construct the [MyApp]
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: RenderLocalVideo(),
      ),
    );
  }
}

