import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:msprmlkit/ar_view.dart';
import 'package:msprmlkit/image_detector.dart';
import 'package:msprmlkit/image_resize_view.dart';
import 'package:msprmlkit/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CameraInput extends StatefulWidget {
  // List<CameraDescription> cameras;
  CameraInput({Key? key, this.cameras}) : super(key: key);

  @override
  State<CameraInput> createState() => _CameraInputState();

  List<CameraDescription>? cameras;
}

class _CameraInputState extends State<CameraInput> {
  CameraController? controller;

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
  Widget build(BuildContext context) {
// final WriteBuffer allBytes = WriteBuffer();
// for (Plane plane in cameraImage.planes) {
//   allBytes.putUint8List(plane.bytes);
// }
// final bytes = allBytes.done().buffer.asUint8List();

// final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

// final InputImageRotation imageRotation =
//     InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
//         InputImageRotation.Rotation_0deg;

// final InputImageFormat inputImageFormat =
//     InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
//         InputImageFormat.NV21;

// final planeData = cameraImage.planes.map(
//   (Plane plane) {
//     return InputImagePlaneMetadata(
//       bytesPerRow: plane.bytesPerRow,
//       height: plane.height,
//       width: plane.width,
//     );
//   },
// ).toList();

// final inputImageData = InputImageData(
//   size: imageSize,
//   imageRotation: imageRotation,
//   inputImageFormat: inputImageFormat,
//   planeData: planeData,
// );

// final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    if (!controller!.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: ResponsiveSizer(builder: (context, orientation, screentype) {
        return CameraPreview(
          controller!,
          child: Container(
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
                  final image = await controller!.takePicture();
                  print(image.path);
                  final inputImage = InputImage.fromFilePath(image.path);
                  const CustomLocalModel localModel = CustomLocalModel.asset;
                  final imageLabeler = GoogleMlKit.vision.imageLabeler(
                      CustomImageLabelerOptions(
                          customModel: localModel,
                          customModelPath: "model-moldav.tflite"));
                  List imageprocessor = await ImageDetector(
                          path: image.path,
                          inputImage: inputImage,
                          image: image)
                      .image_pyramids();
                  List<ImageLabel> labels =
                      await imageLabeler.processImage(imageprocessor[1]);

                  for (ImageLabel label in labels) {
                    String text = label.label;
                    int index = label.index;
                    double confidence = label.confidence;
                    print(text);
                    print(confidence);

                    if (text == "singe") {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: ((context) => ImageResizedView(
                      //               image: imageprocessor[0],
                      //               colors: imageprocessor[2],
                      //             ))));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => HelloWorld())));
                      break;
                    }
                  }
                  imageLabeler.close();
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width / 2,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3,
                    ),
                    //left: MediaQuery.of(context).size.width / 3),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.1),
                        border: Border.all(
                            width: 2.0,
                            color: Colors.grey.shade900.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  //   Icon(Icons.camera_alt)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
