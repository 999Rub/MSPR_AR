import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:msprmlkit/ar_view.dart';
import 'package:msprmlkit/image_detector.dart';
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

                        const InputImageRotation imageRotation =
                            InputImageRotation.Rotation_0deg;

                        const InputImageFormat inputImageFormat =
                            InputImageFormat.NV21;
                        final inputImageData = InputImageData(
                          size: imageSize,
                          imageRotation: imageRotation,
                          inputImageFormat: inputImageFormat,
                          planeData: planeData,
                        );

                        //  print(await _readFileByte(image.path));
                        final inputImageBytes = InputImage.fromBytes(
                            bytes: bytes!, inputImageData: inputImageData);

                        const CustomLocalModel localModel =
                            CustomLocalModel.asset;
                        final imageLabeler = GoogleMlKit.vision.imageLabeler(
                            CustomImageLabelerOptions(
                                customModel: localModel,
                                customModelPath: "model-moldav.tflite"));

                        List imageprocessor = await ImageDetector(
                                path: inputImageBytes.filePath!,
                                inputImage: inputImageBytes,
                                image: XFile.fromData(inputImageBytes.bytes!))
                            .image_pyramids();
                        List<ImageLabel> labels =
                            await imageLabeler.processImage(imageprocessor[1]);
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
