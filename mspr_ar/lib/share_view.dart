import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_stepper/stepper.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareView extends StatefulWidget {
  File screenshot;
  ShareView({Key? key, required this.screenshot}) : super(key: key);

  @override
  State<ShareView> createState() => _ShareViewState();
}

enum Share {
  twitter,
  whatsapp,
  share_instagram,
}

ImagePicker picker = ImagePicker();
bool videoEnable = false;

class _ShareViewState extends State<ShareView> {
  int activeStep = 0; // Initial step set to 0.

  // OPTIONAL: can be set directly.
  int dotCount = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: FractionalOffset.center,
            child: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    cursorRadius: const Radius.circular(10),
                    decoration: InputDecoration(
                      labelText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: TextFormField(
                    cursorRadius: const Radius.circular(10),
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: socialMedia(widget.screenshot)),
              SizedBox(
                height: 20,
              ),
            ],
          )
        ],
      ),
    );
  }
}

Widget socialMedia(File screenshot) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      const SizedBox(height: 30),
      IconButton(
          onPressed: () => onButtonTap(Share.twitter, screenshot),
          icon: const FaIcon(FontAwesomeIcons.twitter,
              color: Color.fromARGB(255, 71, 71, 71))),
      IconButton(
        onPressed: () => onButtonTap(Share.whatsapp, screenshot),
        icon: const FaIcon(FontAwesomeIcons.whatsapp,
            color: Color.fromARGB(255, 71, 71, 71)),
      ),
      IconButton(
        onPressed: () => onButtonTap(Share.share_instagram, screenshot),
        icon: const FaIcon(FontAwesomeIcons.instagram,
            color: Color.fromARGB(255, 71, 71, 71)),
      ),
    ],
  );
}

Future<void> onButtonTap(Share share, File screenshot) async {
  String msg =
      'Flutter share is great!!\n Check out full example at https://pub.dev/packages/flutter_share_me';
  String url = 'https://pub.dev/packages/flutter_share_me';

  String? response;
  final FlutterShareMe flutterShareMe = FlutterShareMe();
  switch (share) {
    case Share.twitter:
      response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
      break;
    case Share.whatsapp:
      if (screenshot.path != null) {
        response = await flutterShareMe.shareToWhatsApp(
            imagePath: screenshot.path,
            fileType: videoEnable ? FileType.video : FileType.image);
      } else {
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
      }
      break;

    case Share.share_instagram:
      response = await flutterShareMe.shareToInstagram(
          filePath: screenshot.path,
          fileType: videoEnable ? FileType.video : FileType.image);
      break;
  }
  debugPrint(response);
}
