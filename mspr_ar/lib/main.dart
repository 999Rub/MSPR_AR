import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msprmlkit/ar_view.dart';
import 'package:msprmlkit/camera_input.dart';
import 'package:msprmlkit/live_view.dart';

List<CameraDescription>? camera;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  camera = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ObjectDetectorView(
        cameras: camera!,
      ),
      //     body: CameraInput(
      //   cameras: camera,
      // )

      // Center(
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.all(50),
      //         child: CupertinoButton(
      //             child: Text("Camera"),
      //             onPressed: () {
      //               Navigator.push(
      //                   context,
      //                   MaterialPageRoute(
      //                       builder: ((context) =>
      //                           CameraInput(cameras: camera))));
      //             }),
      //       ),
      //       CupertinoButton(
      //           child: Text("Ar View"),
      //           onPressed: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: ((context) => HelloWorld())));
      //           })
      //     ],
      //   ),
      // ),
    );
  }
}
