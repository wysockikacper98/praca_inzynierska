import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  final String imageAssetsPath;
  final int tag;
  FullScreenImage({this.imageAssetsPath, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white30,
        child: Hero(
          tag: tag,
          child: PhotoView(
            minScale: 0.5,
            maxScale: 2.0,
            initialScale: 0.75,
            imageProvider: AssetImage(imageAssetsPath),
          ),
        ),
      ),
    );
  }
}
