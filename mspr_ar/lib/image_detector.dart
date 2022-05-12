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
    List<Color> extractedColors = extractPixelsColors(newbytes);
    List cropedDatas = [cropedimge, cropedInput, extractedColors];
    // print(img);
    return cropedDatas;
  }

  List<Color> extractPixelsColors(Uint8List? bytes) {
    List<Color> colors = [];
    int noOfPixelsPerAxis = 12;

    List<int> values = bytes!.buffer.asUint8List();
    imglib.Image? image = imglib.decodeImage(values);

    List<int?> pixels = [];

    int? width = image?.width;
    int? height = image?.height;

    int xChunk = width! ~/ (noOfPixelsPerAxis + 1);
    int yChunk = height! ~/ (noOfPixelsPerAxis + 1);

    for (int j = 1; j < noOfPixelsPerAxis + 1; j++) {
      for (int i = 1; i < noOfPixelsPerAxis + 1; i++) {
        int? pixel = image?.getPixel(xChunk * i, yChunk * j);
        pixels.add(pixel);
        colors.add(abgrToColor(pixel!));
      }
    }

    return colors;
  }

  Color abgrToColor(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
    return Color(hex);
  }
}
