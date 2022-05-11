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

  Future<Map<List<Image>, List<InputImage>>> image_pyramids() async {
    List<InputImage> listInputImage = [];
    List<Image> listImage = [];
    var bytes = await image.readAsBytes();
    imglib.Image src = imglib.decodeImage(bytes)!;
    int offsetX = 0;
    int offsetY = 0;
    var cropSizeW = (src.width / 2).round();
    var cropSizeH = (src.height / 2).round();
    for (; offsetX < src.width; offsetX += cropSizeW) {
      print("OFFESTX : $offsetX");
      offsetY = 0;
      for (; offsetY < src.height; offsetY += cropSizeH) {
        print("OFFSETY $offsetY");
        imglib.Image croped =
            imglib.copyCrop(src, offsetX, offsetY, cropSizeW, cropSizeH);

        var jpg = imglib.encodeJpg(croped);
        String base64 = Base64Encoder().convert(jpg);
        Uint8List newbytes = Base64Decoder().convert(base64);
        //Image img = Image.memory(await image.readAsBytes());

        Image cropedimge = Image.memory(newbytes);

        File file = await File(path).writeAsBytes(newbytes);
        InputImage cropedInput = InputImage.fromFile(file);
        listImage.add(cropedimge);
        listInputImage.add(cropedInput);
      }
    }

    Map<List<Image>, List<InputImage>> cropedDatas = {
      listImage: listInputImage
    };
    // print(img);
    return cropedDatas;
  }
}
