import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../helpers/firebase_storage.dart';

class FullScreenImage extends StatelessWidget {
  final String imageURLPath;
  final int tag;
  final bool editable;

  FullScreenImage(
      {required this.imageURLPath, required this.tag, this.editable = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editable
          ? AppBar(
              backgroundColor: Colors.black,
              actions: [
                Row(
                  children: [
                    Text('Usuń zdjęcie: '),
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).errorColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteImageFromStorage(context, imageURLPath);
                      },
                    ),
                  ],
                )
              ],
            )
          : null,
      body: Container(
        color: Colors.white30,
        child: Hero(
          tag: tag,
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.contained * 2.0,
            initialScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(imageURLPath),
          ),
        ),
      ),
    );
  }
}
