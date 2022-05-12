import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;

class ImageDetector {
  final XFile image;
  final InputImage? inputImage;
  final String path;
  ImageDetector({required this.image, this.inputImage, required this.path});

  Future<List> image_pyramids() async {
    var bytes = await image.readAsBytes();
    imglib.Image src = imglib.decodeImage(bytes)!;
    int offsetX = ((src.width / 3)).round();
    int offsetY = ((src.height / 3)).round();
    var cropSizeW = (src.width / 2.5).round();
    var cropSizeH = (src.height / 3.5).round();
    imglib.Image croped =
        imglib.copyCrop(src, offsetX, offsetY, cropSizeW, cropSizeH);

    var jpg = imglib.encodeJpg(croped);
    String base64 = Base64Encoder().convert(jpg);
    Uint8List newbytes = Base64Decoder().convert(base64);
    //Image img = Image.memory(await image.readAsBytes());

    Image cropedimge = Image.memory(newbytes);

    File file = await File(path).writeAsBytes(newbytes);
    InputImage cropedInput = InputImage.fromFile(file);
    List cropedDatas = [cropedimge, cropedInput];
    // print(img);
    return cropedDatas;
  }
}
