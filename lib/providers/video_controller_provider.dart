import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoControllerNotifier extends StateNotifier<VideoPlayerController?> {
  VideoControllerNotifier() : super(null) {
    _initialize();
  }

  void _initialize() async {
    final controller = VideoPlayerController.asset('assets/videos/chatBg.mp4');
    await controller.initialize();
    controller.setLooping(true);
    controller.play();
    state = controller;
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final videoControllerProvider =
    StateNotifierProvider<VideoControllerNotifier, VideoPlayerController?>(
        (ref) {
  return VideoControllerNotifier();
});
