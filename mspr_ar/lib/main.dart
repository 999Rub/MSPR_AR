import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msprmlkit/ar_view.dart';
import 'package:msprmlkit/camera_input.dart';

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
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
        body: CameraInput(
      cameras: camera,
    )

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
