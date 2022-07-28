import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;
import 'package:color/color.dart' as color;

class ImageDetector {
  final XFile? image;
  final InputImage? inputImage;
  final String? path;
  ImageDetector({
    this.image,
    this.inputImage,
    this.path,
  });

  Future<List> image_pyramids() async {
    var bytes = await image!.readAsBytes();
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

    File file = await File(path!).writeAsBytes(newbytes);
    InputImage cropedInput = InputImage.fromFile(file);
    // List<Color> extractedColors = extractPixelsColors(newbytes);
    List cropedDatas = [
      cropedimge,
      cropedInput,
      newbytes,
    ];
    //  print(extractedColors);
    return cropedDatas;
  }

  Map<String, List> extractPixelsColors(Uint8List? bytes, [String? dessin]) {
    List<Color> colors = [];
    int noOfPixelsPerAxis = 24;

    List<int> values = bytes!.buffer.asUint8List();
    imglib.Image? image = imglib.decodeImage(values);

    List<int?> pixels = [];

    int? width = image?.width;
    int? height = image?.height;

    int xChunk = width! ~/ (noOfPixelsPerAxis + 1);
    int yChunk = height! ~/ (noOfPixelsPerAxis + 1);
    print("Widht : $width, Height : $height, xChunk: $xChunk, yChunk: $yChunk");
    for (int j = 1; j < noOfPixelsPerAxis + 1; j++) {
      for (int i = 1; i < noOfPixelsPerAxis + 1; i++) {
        int? pixel = image?.getPixel(xChunk * i, yChunk * j);
        // print("xChunk : ${xChunk * i} et yChunk : ${yChunk * j}");
        pixels.add(pixel);
        colors.add(
            abgrToColor(pixel!, xChunk * i, yChunk * j, width, height, dessin));
      }
    }
    //print(final_colors_name);
    clearFinalColors();
    print(mapping_colors);
    return mapping_colors;
  }

  List final_colors_name = [];
  Map<String, List> mapping_colors = {
    'zone1': [],
    'zone2': [],
    'zone3': [],
    'zone4': [],
    "zone5": []
  };

  Color abgrToColor(int argbColor, int xChunk, int yChunk, int width, int heigh,
      [String? dessin]) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
    Color color_from_hex = Color(hex);

    List rgb = [color_from_hex.red, color_from_hex.green, color_from_hex.blue];

    switch (dessin) {
      case "singe":
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (0 < yChunk && heigh * 0.5 > yChunk) {
            mapping_colors['zone1']?.addAll(getColorName(rgb));
          }
        }
        if (width * 0.4 < xChunk && xChunk < width * 0.6) {
          if (heigh * 0.15 < yChunk && heigh * 0.4 > yChunk) {
            mapping_colors['zone2']?.addAll(getColorName(rgb));
          }
        }

        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (heigh * 0.5 < yChunk && heigh * 0.8 > yChunk) {
            mapping_colors['zone4']?.addAll(getColorName(rgb));
          }
        }
        // if (width * 0.2 < xChunk && xChunk < width * 0.8) {
        //   if (heigh * 0.9 <= yChunk && heigh >= yChunk) {
        //     mapping_colors['zone5']?.addAll(getColorName(rgb));
        //   }
        // }
        break;
      case 'rhino':
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (0 < yChunk && heigh * 0.1 > yChunk) {
            mapping_colors['zone1']?.addAll(getColorName(rgb));
          }
        }
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (heigh * 0.4 < yChunk && heigh * 0.7 > yChunk) {
            mapping_colors['zone2']?.addAll(getColorName(rgb));
          }
        }
        if (width * 0.5 < xChunk && xChunk < width * 0.6) {
          if (heigh * 0.4 < yChunk && heigh * 0.5 > yChunk) {
            mapping_colors['zone3']?.addAll(getColorName(rgb));
          }
        }
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (heigh * 0.8 < yChunk && heigh > yChunk) {
            mapping_colors['zone4']?.addAll(getColorName(rgb));
          }
        }
        // if (width * 0.2 < xChunk && xChunk < width * 0.8) {
        //   if (heigh * 0.9 <= yChunk && heigh >= yChunk) {
        //     mapping_colors['zone5']?.addAll(getColorName(rgb));
        //   }
        // }
        break;
      case 'serpent':
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (0 < yChunk && heigh * 0.2 > yChunk) {
            mapping_colors['zone1']?.addAll(getColorName(rgb));
          }
        }
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (heigh * 0.2 < yChunk && heigh * 0.3 > yChunk) {
            mapping_colors['zone2']?.addAll(getColorName(rgb));
          }
        }
        if (width * 0.2 < xChunk && xChunk < width * 0.8) {
          if (heigh * 0.4 < yChunk && heigh > yChunk) {
            mapping_colors['zone3']?.addAll(getColorName(rgb));
          }
        }

        break;
      default:
    }

    return Color(hex);
  }

  List getColorName(List rgb) {
    List colors_to_returns = [];
    List keywords = [
      'blue',
      'red',
      'green',
      'yellow',
      'purple',
      'pink',
      'brown',
      'white',
      'orange'
    ];
    var diff_temp = null;
    String temp_color = '';
    for (var color in colors_tab.entries) {
      int diff = 0;
      String col = '';
      for (var i = 0; i < color.value.length; i++) {
        diff += pow(rgb[i] - color.value[i], 2).toInt();
        col = color.key;
      }
      if (diff_temp != null) {
        if (diff < diff_temp) {
          diff_temp = diff;
          temp_color = col;
        }
      } else {
        diff_temp = diff;
        temp_color = col;
      }
    }
    for (var color in keywords) {
      if (temp_color.contains(color)) {
        colors_to_returns.add(color);
        final_colors_name.add(color);
        break;
      }
    }
    return colors_to_returns;
  }

  void clearFinalColors() {
    for (var colors in mapping_colors.entries) {
      for (var i = 0; i < colors.value.length; i++) {
        if (colors.value[i] == 'brown' || colors.value[i] == 'orange') {
          mapping_colors[colors.key]?[i] = 'red';
        }
      }
      final Map counts = {};
      String most_occurate_color = 'white';
      int counter = 0;
      //  counts.containsKey(e) ? counts[e]++ : counts[e] = 1
      colors.value.forEach((element) => counts.containsKey(element)
          ? counts[element]++
          : counts[element] = 1);
      counts.forEach((key, value) {
        if (counter != 0) {
          if (value > counter) {
            counter = value;
            most_occurate_color = key;
          }
        } else {
          counter = value;
          most_occurate_color = key;
        }
      });
      mapping_colors[colors.key] = [most_occurate_color];
      // print(counts);
      // print(most_occurate_color);
    }
  }

  final Map<String, List> colors_tab = {
    "aliceblue": [240, 248, 255],
    "antiquewhite": [250, 235, 215],
    "aqua": [0, 255, 255],
    "aquamarine": [127, 255, 212],
    "azure": [240, 255, 255],
    "beige": [245, 245, 220],
    "bisque": [255, 228, 196],
    "black": [0, 0, 0],
    "blanchedalmond": [255, 235, 205],
    "blue": [0, 0, 255],
    "blueviolet": [138, 43, 226],
    "brown": [165, 42, 42],
    "burlywood": [222, 184, 135],
    "cadetblue": [95, 158, 160],
    "chartreuse": [127, 255, 0],
    "chocolate": [210, 105, 30],
    "coral": [255, 127, 80],
    "cornflowerblue": [100, 149, 237],
    "cornsilk": [255, 248, 220],
    "crimson": [220, 20, 60],
    "cyan": [0, 255, 255],
    "darkblue": [0, 0, 139],
    "darkcyan": [0, 139, 139],
    "darkgoldenrod": [184, 134, 11],
    "darkgray": [169, 169, 169],
    "darkgreen": [0, 100, 0],
    "darkgrey": [169, 169, 169],
    "darkkhaki": [189, 183, 107],
    "darkmagenta": [139, 0, 139],
    "darkolivegreen": [85, 107, 47],
    "darkorange": [255, 140, 0],
    "darkorchid": [153, 50, 204],
    "darkred": [139, 0, 0],
    "darksalmon": [233, 150, 122],
    "darkseagreen": [143, 188, 143],
    "darkslateblue": [72, 61, 139],
    "darkslategray": [47, 79, 79],
    "darkslategrey": [47, 79, 79],
    "darkturquoise": [0, 206, 209],
    "darkviolet": [148, 0, 211],
    "deeppink": [255, 20, 147],
    "deepskyblue": [0, 191, 255],
    "dimgray": [105, 105, 105],
    "dimgrey": [105, 105, 105],
    "dodgerblue": [30, 144, 255],
    "firebrick": [178, 34, 34],
    "floralwhite": [255, 250, 240],
    "forestgreen": [34, 139, 34],
    "fuchsia": [255, 0, 255],
    "gainsboro": [220, 220, 220],
    "ghostwhite": [248, 248, 255],
    "gold": [255, 215, 0],
    "goldenrod": [218, 165, 32],
    "gray": [128, 128, 128],
    "green": [0, 128, 0],
    "greenyellow": [173, 255, 47],
    "grey": [128, 128, 128],
    "honeydew": [240, 255, 240],
    "hotpink": [255, 105, 180],
    "indianred": [205, 92, 92],
    "indigo": [75, 0, 130],
    "ivory": [255, 255, 240],
    "khaki": [240, 230, 140],
    "lavender": [230, 230, 250],
    "lavenderblush": [255, 240, 245],
    "lawngreen": [124, 252, 0],
    "lemonchiffon": [255, 250, 205],
    "lightblue": [173, 216, 230],
    "lightcoral": [240, 128, 128],
    "lightcyan": [224, 255, 255],
    "lightgoldenrodyellow": [250, 250, 210],
    "lightgray": [211, 211, 211],
    "lightgreen": [144, 238, 144],
    "lightgrey": [211, 211, 211],
    "lightpink": [255, 182, 193],
    "lightsalmon": [255, 160, 122],
    "lightseagreen": [32, 178, 170],
    "lightskyblue": [135, 206, 250],
    "lightslategray": [119, 136, 153],
    "lightslategrey": [119, 136, 153],
    "lightsteelblue": [176, 196, 222],
    "lightyellow": [255, 255, 224],
    "lime": [0, 255, 0],
    "limegreen": [50, 205, 50],
    "linen": [250, 240, 230],
    "magenta": [255, 0, 255],
    "maroon": [128, 0, 0],
    "mediumaquamarine": [102, 205, 170],
    "mediumblue": [0, 0, 205],
    "mediumorchid": [186, 85, 211],
    "mediumpurple": [147, 112, 219],
    "mediumseagreen": [60, 179, 113],
    "mediumslateblue": [123, 104, 238],
    "mediumspringgreen": [0, 250, 154],
    "mediumturquoise": [72, 209, 204],
    "mediumvioletred": [199, 21, 133],
    "midnightblue": [25, 25, 112],
    "mintcream": [245, 255, 250],
    "mistyrose": [255, 228, 225],
    "moccasin": [255, 228, 181],
    "navajowhite": [255, 222, 173],
    "navy": [0, 0, 128],
    "oldlace": [253, 245, 230],
    "olive": [128, 128, 0],
    "olivedrab": [107, 142, 35],
    "orange": [255, 165, 0],
    "orangered": [255, 69, 0],
    "orchid": [218, 112, 214],
    "palegoldenrod": [238, 232, 170],
    "palegreen": [152, 251, 152],
    "paleturquoise": [175, 238, 238],
    "palevioletred": [219, 112, 147],
    "papayawhip": [255, 239, 213],
    "peachpuff": [255, 218, 185],
    "peru": [205, 133, 63],
    "pink": [255, 192, 203],
    "plum": [221, 160, 221],
    "powderblue": [176, 224, 230],
    "purple": [128, 0, 128],
    "rebeccapurple": [102, 51, 153],
    "red": [255, 0, 0],
    "rosybrown": [188, 143, 143],
    "royalblue": [65, 105, 225],
    "saddlebrown": [139, 69, 19],
    "salmon": [250, 128, 114],
    "sandybrown": [244, 164, 96],
    "seagreen": [46, 139, 87],
    "seashell": [255, 245, 238],
    "sienna": [160, 82, 45],
    "silver": [192, 192, 192],
    "skyblue": [135, 206, 235],
    "slateblue": [106, 90, 205],
    "slategray": [112, 128, 144],
    "slategrey": [112, 128, 144],
    "snow": [255, 250, 250],
    "springgreen": [0, 255, 127],
    "steelblue": [70, 130, 180],
    "tan": [210, 180, 140],
    "teal": [0, 128, 128],
    "thistle": [216, 191, 216],
    "tomato": [255, 99, 71],
    "turquoise": [64, 224, 208],
    "violet": [238, 130, 238],
    "wheat": [245, 222, 179],
    "white": [255, 255, 255],
    "whitesmoke": [245, 245, 245],
    "yellow": [255, 255, 0],
    "yellowgreen": [154, 205, 50]
  };
}
