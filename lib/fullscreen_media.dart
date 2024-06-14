import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart'; // Certifique-se de importar

class FullScreenMedia extends StatefulWidget {
  final String mediaPath;
  final bool isWeb;
  final bool isVideo;

  FullScreenMedia({required this.mediaPath, required this.isWeb, required this.isVideo});

  @override
  _FullScreenMediaState createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<FullScreenMedia> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = widget.isWeb
          ? VideoPlayerController.network(widget.mediaPath)
          : VideoPlayerController.file(File(widget.mediaPath))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
          tag: widget.mediaPath,
          child: widget.isVideo
              ? _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
              : CircularProgressIndicator()
              : widget.isWeb
              ? CachedNetworkImage(
            imageUrl: widget.mediaPath,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
              : Image.file(File(widget.mediaPath)),
        ),
      ),
      floatingActionButton: widget.isVideo
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      )
          : null,
    );
  }
}
