import 'dart:io';
import 'dart:typed_data';

import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msprmlkit/image_detector.dart';
import 'package:msprmlkit/share_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:native_screenshot/native_screenshot.dart';

class ArScreen extends StatefulWidget {
  String dessin;
  Uint8List newbytes;
  ArScreen({required this.dessin, required this.newbytes});
  @override
  _ArScreenState createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ArCoreController? arCoreController;
  //String localObjectReference;
  ARNode? localObjectNode;
  //String webObjectReference;
  ARNode? fileSystemNode;
  HttpClient? httpClient;
  ARNode? webObjectNode;
  late ARKitController arkitController;
  ARKitReferenceNode? node;
  late Map<String, List> mapping_color;
  int _counter = 0;
  Uint8List? _imageFile;
  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    mapping_color =
        ImageDetector().extractPixelsColors(widget.newbytes, widget.dessin);
    for (var color in mapping_color.entries) {
      if (color.value.isEmpty || color.value == []) {
        mapping_color[color.key]!.add("white");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
          body: Container(
              child: Stack(children: [
        // ARKitSceneView(
        //   onARKitViewCreated: onARKitViewCreated,
        // ),

        ARView(
          onARViewCreated: onARViewCreated,
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: ElevatedButton(
              onPressed: () async {
                String? path = await NativeScreenshot.takeScreenshot()
                    .then((String? path) {
                  File screenshot = File(path!);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => ShareView(
                                screenshot: screenshot,
                              ))));
                });
                // await screenshotController
                //     .capture(delay: const Duration(milliseconds: 10))
                //     .then((Uint8List? image) async {
                //   if (image != null) {
                //     final directory =
                //         await getApplicationDocumentsDirectory();
                //     final imagePath =
                //         await File('${directory.path}/image.png').create();
                //     await imagePath.writeAsBytes(image);
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: ((context) => ShareView(
                //                   screenshot: imagePath,
                //                 ))));
                //   }
                // });

                const CupertinoActionSheet(
                  title: Text("Share on social media"),
                );
              },
              child: Text("SHARE")),
        ),
        Align(
          alignment: FractionalOffset.topLeft,
          child: Image.asset('assets/logo.png'),
        )
      ]))),
    );
  }

  // void onARKitViewCreated(ARKitController arkitController) {
  //   this.arkitController = arkitController;
  //   arkitController.addCoachingOverlay(CoachingOverlayGoal.horizontalPlane);
  //   _addPlane(this.arkitController);
  // }

  // void _addPlane(ARKitController controller) {
  //   if (node != null) {
  //     controller.remove(node!.name);
  //   }
  //   node = ARKitReferenceNode(
  //     url: 'cube.obj',
  //     scale: vector.Vector3.all(0.3),
  //   );
  //   controller.add(node!);
  // }
  Future<void> onTakeScreenshot() async {
    var image = await this.arSessionManager!.snapshot();
    await showDialog(
        context: context,
        builder: (_) => Dialog(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(image: image, fit: BoxFit.cover)),
              ),
            ));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager?.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          showAnimatedGuide: false,
          //  customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: false,
          handleTaps: true,
        );
    this.arObjectManager?.onInitialize();

    Future<void> onLocalObjectAtOriginButtonPressed() async {
      if (localObjectNode != null) {
        this.arObjectManager?.removeNode(localObjectNode!);
        localObjectNode = null;
      } else {
        switch (widget.dessin) {
          case "singe":
            var zone1 = ARNode(
              // tete oreilles
              type: NodeType.localGLTF2,
              uri:
                  "assets/zone1-${widget.dessin}-${mapping_color['zone1']!.isNotEmpty ? "white" : mapping_color['zone1']?.first.toString()}.gltf",
              scale: vector.Vector3(0.1, 0.1, 0.1),
              position: vector.Vector3(0, -0.1, -0.1),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone2 = ARNode(
              // yeux et nez
              type: NodeType.localGLTF2,
              uri: mapping_color['zone2']!.isNotEmpty
                  ? "assets/zone2-${widget.dessin}-${mapping_color['zone2']?.first.toString()}.gltf"
                  : "assets/zone2-singe-white.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.08, -0.1),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone4 = ARNode(
                // corps
                type: NodeType.localGLTF2,
                uri: mapping_color['zone4']!.isNotEmpty
                    ? "assets/zone4-singe-${mapping_color['zone4']?.first.toString()}.gltf"
                    : "assets/zone4-singe-white.gltf",
                scale: vector.Vector3(0.1, 0.1, 0.1),
                position: vector.Vector3(0, -0.2, -0.1),
                rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            var zone5 = ARNode(
                // main et pieds
                type: NodeType.localGLTF2,
                uri: mapping_color['zone5']!.isNotEmpty
                    ? "assets/zone5-singe-${mapping_color['zone5']?.first.toString()}.gltf"
                    : "assets/zone5-singe-white.gltf",
                scale: vector.Vector3(0.05, 0.05, 0.05),
                position: vector.Vector3(0, -0.15, -0.04),
                rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            bool? didAddLocalNode = await this.arObjectManager?.addNode(zone1);
            await this.arObjectManager?.addNode(zone4);
            await this.arObjectManager?.addNode(zone5);
            await this.arObjectManager?.addNode(zone2);

            //localObjectNode = (didAddLocalNode!) ? head : null;
            break;
          case "rhino":
            var zone1 = ARNode(
              // tete oreilles
              type: NodeType.localGLTF2,
              uri:
                  "assets/zone1-${widget.dessin}-${mapping_color['zone1']!.isNotEmpty ? "white" : mapping_color['zone1']?.first.toString()}.gltf",
              scale: vector.Vector3(0.1, 0.1, 0.1),
              position: vector.Vector3(0, -0.1, -0.1),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone2 = ARNode(
              // yeux et nez
              type: NodeType.localGLTF2,
              uri:
                  "assets/zone2-${widget.dessin}-${mapping_color['zone2']!.isNotEmpty ? "white" : mapping_color['zone2']?.first.toString()}.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.11, -0.065),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone3 = ARNode(
              // yeux et nez
              type: NodeType.localGLTF2,
              uri: mapping_color['zone3']!.isNotEmpty
                  ? "assets/zone3-${widget.dessin}-${mapping_color['zone3']?.first.toString()}.gltf"
                  : "assets/zone3-rhino-white.gltf",
              scale: vector.Vector3(0.025, 0.025, 0.025),
              position: vector.Vector3(0, -0.095, 0),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone4 = ARNode(
                // corps
                type: NodeType.localGLTF2,
                uri: mapping_color['zone4']!.isNotEmpty
                    ? "assets/zone4-rhino-${mapping_color['zone4']?.first.toString()}.gltf"
                    : "assets/zone4-rhino-white.gltf",
                scale: vector.Vector3(0.1, 0.1, 0.1),
                position: vector.Vector3(0, -0.2, -0.1),
                rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            // var zone5 = ARNode(
            //     // main et pieds
            //     type: NodeType.localGLTF2,
            //     uri: mapping_color['zone5']!.isNotEmpty
            //         ? "assets/zone5-rhino-${mapping_color['zone5']?.first.toString()}.gltf"
            //         : "assets/zone5-rhino-white.gltf",
            //     scale: vector.Vector3(0.05, 0.05, 0.05),
            //     position: vector.Vector3(0, -0.15, -0.04),
            //     rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            bool? didAddLocalNode = await this.arObjectManager?.addNode(zone1);
            await this.arObjectManager?.addNode(zone4);
            await this.arObjectManager?.addNode(zone3);
            await this.arObjectManager?.addNode(zone2);
            break;

          case "serpent":
            var zone1 = ARNode(
              // tete oreilles
              type: NodeType.localGLTF2,
              uri:
                  "assets/zone1-${widget.dessin}-${mapping_color['zone1']!.isNotEmpty ? "white" : mapping_color['zone1']?.first.toString()}.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.1, -0.1),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone2 = ARNode(
              // yeux et nez
              type: NodeType.localGLTF2,
              uri:
                  "assets/zone2-${widget.dessin}-${mapping_color['zone2']!.isNotEmpty ? "white" : mapping_color['zone2']?.first.toString()}.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.11, -0.065),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );
            var zone3 = ARNode(
              // yeux et nez
              type: NodeType.localGLTF2,
              uri:
                  "assets/zone3-${widget.dessin}-${mapping_color['zone3']!.isNotEmpty ? "white" : mapping_color['zone3']?.first.toString()}.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.11, -0.065),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            bool? didAddLocalNode = await this.arObjectManager?.addNode(zone1);

            await this.arObjectManager?.addNode(zone2);
            await this.arObjectManager?.addNode(zone3);

            break;
        }
      }
    }

    onLocalObjectAtOriginButtonPressed();
    //onWebObjectAtOriginButtonPressed();
  }
}
