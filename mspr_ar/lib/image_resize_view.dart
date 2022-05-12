import 'package:flutter/material.dart';

class ImageResizedView extends StatelessWidget {
  final Image image;
  final List<Color> colors;
  const ImageResizedView({Key? key, required this.image, required this.colors})
      : super(key: key);

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
          GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: noOfPixelsPerAxis),
              itemCount: colors.length,
              itemBuilder: (BuildContext ctx, index) {
                return Container(
                  alignment: Alignment.center,
                  child: Container(
                    color: colors[index],
                  ),
                );
              })
        ],
      ),
    );
  }
}

List<Color> colors = colors;
int noOfPixelsPerAxis = 12;
