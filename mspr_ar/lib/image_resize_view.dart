import 'package:flutter/material.dart';

class ImageResizedView extends StatelessWidget {
  final Image image;
  const ImageResizedView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(image: image.image);
  }
}
