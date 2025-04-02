import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideo extends StatefulWidget {
  const BackgroundVideo({super.key, required this.videoPath, required this.isLooping, required this.isMuted});

  final String videoPath;
  final bool isLooping;
  final bool isMuted;

  @override
  State<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late VideoPlayerController _controller;

  late Future<void> _initializeVideoPlayerFuture1;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoPath);
    _initializeVideoPlayerFuture1 = _controller.initialize().then((_) {
      _controller.setLooping(widget.isLooping);
      _controller.setVolume(widget.isMuted ? 0 : 1);
      _controller.play();
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      _controller.play();
    }
    print('Video initialized: ${_controller.value.isInitialized}');
    return Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture1,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
    );
  }
}
