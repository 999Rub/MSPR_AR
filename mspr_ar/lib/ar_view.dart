import 'dart:io';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
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
//import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

class HelloWorld extends StatefulWidget {
  @override
  _HelloWorldState createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ArCoreController? arCoreController;
  String? localObjectReference;
  ARNode? localObjectNode;
  String? webObjectReference;
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
      ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
      // ARKitSceneView(
      //   onARKitViewCreated: onARKitViewCreated,
      // ),
      // ARView(onARViewCreated: onARViewCreated)
    ]))));
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    var coreref = ArCoreReferenceNode(
      name: 'cube',
      object3DFileName: "cube.sfb",
      // objectUrl:
      //     "https://https://github.com/999Rub/MSPR_AR/blob/main/mspr_ar/assets/singe.gltf",
    );
    final material = ArCoreMaterial(color: Colors.blue);

    //coreref.shape?.materials.value = [ArCoreMaterial(color: Colors.red)];

    final cube =
        ArCoreCube(size: vector.Vector3(0.5, 0.5, 0.5), materials: [material]);
    final node = ArCoreNode(shape: cube);
    //coreref.shape!.materials = ArCoreMaterial();
    controller.addArCoreNode(node);
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
          showPlanes: false,
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
        var newNode = ARNode(
            type: NodeType.localGLTF2,
            uri: "assets/singe.gltf",
            scale: vector.Vector3(0.2, 0.2, 0.2),
            position: vector.Vector3(0.0, 0.0, 0.0),
            rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddLocalNode = await this.arObjectManager?.addNode(newNode);
        localObjectNode = (didAddLocalNode!) ? newNode : null;
      }
    }

    Future<void> onWebObjectAtOriginButtonPressed() async {
      if (webObjectNode != null) {
        this.arObjectManager?.removeNode(webObjectNode!);
        webObjectNode = null;
      } else {
        var newNode = ARNode(
            type: NodeType.webGLB,
            uri: "assets/singe.gltf",
            scale: vector.Vector3(0.2, 0.2, 0.2));
        bool? didAddWebNode = await this.arObjectManager?.addNode(newNode);
        webObjectNode = (didAddWebNode!) ? newNode : null;
      }
    }

    onLocalObjectAtOriginButtonPressed();
    //onWebObjectAtOriginButtonPressed();
  }
}
