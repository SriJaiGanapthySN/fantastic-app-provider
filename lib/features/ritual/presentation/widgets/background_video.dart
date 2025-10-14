import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/_providers.dart';

class BackgroundVideo extends ConsumerStatefulWidget {
  const BackgroundVideo({super.key});

  @override
  ConsumerState<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends ConsumerState<BackgroundVideo> {
  late VideoPlayerController _controller1; // morning
  late VideoPlayerController _controller2; // afternoon
  late VideoPlayerController _controller3; // evening
  late VideoPlayerController _controller4; // night

  late Future<void> _initializeVideoPlayerFuture1;
  late Future<void> _initializeVideoPlayerFuture2;
  late Future<void> _initializeVideoPlayerFuture3;
  late Future<void> _initializeVideoPlayerFuture4;

  @override
  void initState() {
    super.initState();

    _controller1 = VideoPlayerController.asset('assets/videos/background1.mp4');
    _initializeVideoPlayerFuture1 = _controller1.initialize().then((_) {
      _controller1.setLooping(true);
      _controller1.play();
    });

    _controller2 = VideoPlayerController.asset('assets/videos/background2.mp4');
    _initializeVideoPlayerFuture2 = _controller2.initialize().then((_) {
      _controller2.setLooping(true);
    });

    _controller3 = VideoPlayerController.asset('assets/videos/background3.mp4');
    _initializeVideoPlayerFuture3 = _controller3.initialize().then((_) {
      _controller3.setLooping(true);
    });

    _controller4 = VideoPlayerController.asset('assets/videos/background4.mp4');
    _initializeVideoPlayerFuture4 = _controller4.initialize().then((_) {
      _controller4.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);

    if (_controller1.value.isPlaying) _controller1.pause();
    if (_controller2.value.isPlaying) _controller2.pause();
    if (_controller3.value.isPlaying) _controller3.pause();
    if (_controller4.value.isPlaying) _controller4.pause();

    switch (videoState.currentVideo) {
      case VideoBackground.morning:
        _controller1.play();
        break;
      case VideoBackground.afternoon:
        _controller2.play();
        break;
      case VideoBackground.evening:
        _controller3.play();
        break;
      case VideoBackground.night:
        _controller4.play();
        break;
    }

    return Stack(
      children: [
        AnimatedOpacity(
          opacity:
              videoState.currentVideo == VideoBackground.morning ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture1,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller1.value.size.width,
                      height: _controller1.value.size.height,
                      child: VideoPlayer(_controller1),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        AnimatedOpacity(
          opacity:
              videoState.currentVideo == VideoBackground.afternoon ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture2,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller2.value.size.width,
                      height: _controller2.value.size.height,
                      child: VideoPlayer(_controller2),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        AnimatedOpacity(
          opacity:
              videoState.currentVideo == VideoBackground.evening ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture3,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller3.value.size.width,
                      height: _controller3.value.size.height,
                      child: VideoPlayer(_controller3),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        AnimatedOpacity(
          opacity: videoState.currentVideo == VideoBackground.night ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture4,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller4.value.size.width,
                      height: _controller4.value.size.height,
                      child: VideoPlayer(_controller4),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}
