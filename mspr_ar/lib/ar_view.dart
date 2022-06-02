import 'dart:io';

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
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

class ArScreen extends StatefulWidget {
  Map<String, List> colors;
  ArScreen({required this.colors});
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

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
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

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    var coreref = ArCoreReferenceNode(
      //object3DFileName: "cube.obj",
      objectUrl:
          "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf",
    );
    coreref.shape?.materials.value = [ArCoreMaterial(color: Colors.red)];
    //coreref.shape!.materials = ArCoreMaterial();
    controller.addArCoreNode(coreref);
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
        var head = ARNode(
          type: NodeType.localGLTF2,
          uri:
              "assets/head-singe-${widget.colors['head']?.first.toString()}.gltf",
          scale: vector.Vector3(0.1, 0.1, 0.1),
          position: vector.Vector3(0, -0.1, -0.1),
          rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
        );

        var body = ARNode(
            type: NodeType.localGLTF2,
            uri: "assets/body-singe-${widget.colors['body']?.first}.gltf",
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
      }
    }

    onLocalObjectAtOriginButtonPressed();
    //onWebObjectAtOriginButtonPressed();
  }
}
