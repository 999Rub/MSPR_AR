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
import 'package:flutter/material.dart';
import 'package:msprmlkit/image_detector.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

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
  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  void initState() {
    super.initState();
    mapping_color =
        ImageDetector().extractPixelsColors(widget.newbytes, widget.dessin);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
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
        child: ElevatedButton(onPressed: () {}, child: Text("SHARE")),
      )
    ]))));
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
          handleTaps: false,
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
              position: vector.Vector3(0, -0.08, -0.04),
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
              uri: mapping_color['zone2']!.isNotEmpty
                  ? "assets/zone2-${widget.dessin}-${mapping_color['zone2']?.first.toString()}.gltf"
                  : "assets/zone2-rhino-white.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.12, -0.75),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var zone3 = ARNode(
              // yeux et nez
              type: NodeType.localGLTF2,
              uri: mapping_color['zone3']!.isNotEmpty
                  ? "assets/zone3-${widget.dessin}-${mapping_color['zone3']?.first.toString()}.gltf"
                  : "assets/zone3-rhino-white.gltf",
              scale: vector.Vector3(0.05, 0.05, 0.05),
              position: vector.Vector3(0, -0.08, -0.04),
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

          default:
        }
      }
    }

    onLocalObjectAtOriginButtonPressed();
    //onWebObjectAtOriginButtonPressed();
  }
}
