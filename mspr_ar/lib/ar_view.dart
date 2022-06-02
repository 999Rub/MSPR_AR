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
      // ArCoreView(
      //   onArCoreViewCreated: _onArCoreViewCreated,
      // ),
      // ARKitSceneView(
      //   onARKitViewCreated: onARKitViewCreated,
      // ),
      ARView(
        onARViewCreated: onARViewCreated,
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
          showWorldOrigin: true,
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
            var head = ARNode(
              type: NodeType.localGLTF2,
              uri:
                  "assets/head-singe-${mapping_color['zone1']?.first.toString()}.gltf",
              scale: vector.Vector3(0.1, 0.1, 0.1),
              position: vector.Vector3(0, -0.1, -0.1),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
            );

            var body = ARNode(
                type: NodeType.localGLTF2,
                uri: "assets/body-singe-${mapping_color['zone2']?.first}.gltf",
                scale: vector.Vector3(0.1, 0.1, 0.1),
                position: vector.Vector3(0, -0.2, -0.1),
                rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            // var lefthand = ARNode(
            //     type: NodeType.localGLTF2,
            //     uri: "assets/mainGaucheSingeVert.gltf",
            //     scale: vector.Vector3(0.05, 0.05, 0.05),
            //     position: vector.Vector3(-0.08, -0.12, -0.06),
            //     rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            // var righthand = ARNode(
            //     type: NodeType.localGLTF2,
            //     uri: "assets/mainDroiteSingeVert.gltf",
            //     scale: vector.Vector3(0.05, 0.05, 0.05),
            //     position: vector.Vector3(0.08, -0.1, -0.07),
            //     rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));

            bool? didAddLocalNode = await this.arObjectManager?.addNode(head);
            await this.arObjectManager?.addNode(body);
            //await this.arObjectManager?.addNode(lefthand);
            //await this.arObjectManager?.addNode(righthand);
            localObjectNode = (didAddLocalNode!) ? head : null;
            break;
          default:
        }
      }
    }

    onLocalObjectAtOriginButtonPressed();
    //onWebObjectAtOriginButtonPressed();
  }
}
