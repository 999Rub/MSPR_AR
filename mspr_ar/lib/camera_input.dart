import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:msprmlkit/ar_view.dart';
import 'package:msprmlkit/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraInput extends StatefulWidget {
  // List<CameraDescription> cameras;
  CameraInput({Key? key, this.cameras}) : super(key: key);

  @override
  State<CameraInput> createState() => _CameraInputState();

  List<CameraDescription>? cameras;
}

class _CameraInputState extends State<CameraInput> {
  CameraController? controller;
  CameraImage? cameraImage;
  bool detected = false;
  Rect? rect;
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras![0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: ResponsiveSizer(builder: (context, orientation, screentype) {
        return CameraPreview(
          controller!,
          child: !detected
              ? Container(
                  height: 30,
                  width: 30,
                  child: CupertinoButton(
                    // Provide an onPressed callback.
                    onPressed: () async {
                      // Take the Picture in a try / catch block. If anything goes wrong,
                      // catch the error.
                      try {
                        // Ensure that the camera is initialized.
                        await widget.cameras;

                        // Attempt to take a picture and then get the location
                        // where the image file is saved.
                        // final image = await controller!.takePicture();

                        controller!.startImageStream(((image) => cameraImage));
                        // print(image.path + ' PHOTO PRISE');
                        // final inputImage = InputImage.fromFilePath(image.path);
                        //  print(inputImage.inputImageData);
                        final WriteBuffer allBytes = WriteBuffer();
                        for (final Plane plane in cameraImage!.planes) {
                          allBytes.putUint8List(plane.bytes);
                        }
                        bytes = allBytes.done().buffer.asUint8List();

                        final planeData = cameraImage!.planes.map(
                          (Plane plane) {
                            return InputImagePlaneMetadata(
                              bytesPerRow: plane.bytesPerRow,
                              height: plane.height,
                              width: plane.width,
                            );
                          },
                        ).toList();
                        final Size imageSize = Size(
                            cameraImage!.width.toDouble(),
                            cameraImage!.height.toDouble());

                        final InputImageRotation imageRotation =
                            InputImageRotation.rotation0deg;

                        final InputImageFormat inputImageFormat =
                            InputImageFormatValue.fromRawValue(
                                    cameraImage!.format.raw) ??
                                InputImageFormat.nv21;
                        final inputImageData = InputImageData(
                          size: imageSize,
                          imageRotation: imageRotation,
                          inputImageFormat: inputImageFormat,
                          planeData: planeData,
                        );

                        //  print(await _readFileByte(image.path));
                        final inputImageBytes = InputImage.fromBytes(
                            bytes: bytes!, inputImageData: inputImageData);

                        final modelPath =
                            await _getModel('assets/ml/detect.tflite');
                        final options = LocalObjectDetectorOptions(
                            mode: DetectionMode.stream,
                            modelPath: modelPath,
                            classifyObjects: true,
                            confidenceThreshold: 0.1,
                            multipleObjects: true);

                        final objectDetector = ObjectDetector(options: options);

                        final List<DetectedObject> objects =
                            await objectDetector.processImage(inputImageBytes);

                        // controller!.stopImageStream();

                        if (objects.isEmpty) {
                          print("AUCUN OBJET RETECTE ");
                        } else {
                          for (var object in objects) {
                            print(object.boundingBox);
                            print(object.labels.first.text);
                          }
                          // print(
                          //     "${objects.first.boundingBox}, ${objects.first.labels.first.index},  ${objects.first.labels.first.text}");
                          setState(() {
                            detected = true;
                            rect = objects.single.boundingBox;
                          });
                        }
                        objectDetector.close();

                        // print("PROCESS IMAGE TERMINE ${objects.length}");
                        // for (DetectedObject detectedObject in objects) {

                        //   final rect = detectedObject.boundingBox;
                        //   final trackingId = detectedObject.trackingId;
                        //   final label = detectedObject.labels;
                        //   print(detectedObject.labels.length);
                        //   for (Label label in detectedObject.labels) {
                        //     print("AFFICHAGE DES INFORMATIONS : ");
                        //     print('${label.index} ${label.confidence} ${label.text}');
                        //   }
                        //   print(rect);
                        //   print(trackingId);
                        // }

                      } catch (e) {
                        // If an error occurs, log the error to the console.
                        print(e);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                )
              : CustomPaint(
                  painter: Box(rect: rect!),
                ),
        );
      }),
    );
  }
}

class Box extends CustomPainter {
  Rect rect;
  Box({required this.rect});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      rect,
      new Paint()
        ..style = PaintingStyle.stroke
        ..color = new Color(0xFF0099FF),
    );
  }

  @override
  bool shouldRepaint(Box oldDelegate) {
    return false;
  }
}
