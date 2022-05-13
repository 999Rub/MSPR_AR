import 'dart:io';

import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

class HelloWorld extends StatefulWidget {
  @override
  _HelloWorldState createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  //String localObjectReference;
  ARNode? localObjectNode;
  //String webObjectReference;
  ARNode? fileSystemNode;
  HttpClient? httpClient;
  ARNode? webObjectNode;

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
      ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
      ),
    ]))));
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
            uri: "Models/rainbow.glb",
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
            uri:
                "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
            scale: vector.Vector3(0.2, 0.2, 0.2));
        bool? didAddWebNode = await this.arObjectManager?.addNode(newNode);
        webObjectNode = (didAddWebNode!) ? newNode : null;
      }
    }

    // onLocalObjectAtOriginButtonPressed();
    onWebObjectAtOriginButtonPressed();
  }
}
