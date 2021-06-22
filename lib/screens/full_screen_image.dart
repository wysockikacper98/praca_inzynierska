import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageAssetsPath;

  FullScreenImage(this.imageAssetsPath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Container(
          color: Colors.white30,
          child: Center(
            child: Hero(
              tag: "first",
              child: Image.asset(imageAssetsPath),
            ),
          ),
        ),
        onTap:() => Navigator.of(context).pop(),
      ),
    );
  }
}
