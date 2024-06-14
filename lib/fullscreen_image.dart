import 'package:flutter/material.dart';
import 'package:universal_io/io.dart'; // Use universal_io
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final bool isWeb;

  FullScreenImage({required this.imagePath, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: isWeb
              ? CachedNetworkImage(
            imageUrl: imagePath,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
              : Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
