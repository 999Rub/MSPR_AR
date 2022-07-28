import 'package:flutter/material.dart';

class ImageResizedView extends StatelessWidget {
  final Image image;
  const ImageResizedView({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Image(
            image: image.image,
            width: 400,
            height: 300,
          ),
        ],
      ),
    );
  }
}

List<Color> colors = colors;
int noOfPixelsPerAxis = 12;
