import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VideoBackground { first, second, third, fourth }

class VideoState {
  final VideoBackground currentVideo;
  final bool isTransitioning;

  VideoState({
    required this.currentVideo,
    this.isTransitioning = false,
  });

  VideoState copyWith({
    VideoBackground? currentVideo,
    bool? isTransitioning,
  }) {
    return VideoState(
      currentVideo: currentVideo ?? this.currentVideo,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }
}

class VideoNotifier extends StateNotifier<VideoState> {
  VideoNotifier() : super(VideoState(currentVideo: VideoBackground.first));

  void switchVideo({bool forward = true}) {
    state = state.copyWith(isTransitioning: true);

    VideoBackground newVideo;
    if (forward) {
      switch (state.currentVideo) {
        case VideoBackground.first:
          newVideo = VideoBackground.second;
          break;
        case VideoBackground.second:
          newVideo = VideoBackground.third;
          break;
        case VideoBackground.third:
          newVideo = VideoBackground.fourth;
          break;
        case VideoBackground.fourth:
          newVideo = VideoBackground.first;
          break;
      }
    } else {
      switch (state.currentVideo) {
        case VideoBackground.first:
          newVideo = VideoBackground.fourth;
          break;
        case VideoBackground.second:
          newVideo = VideoBackground.first;
          break;
        case VideoBackground.third:
          newVideo = VideoBackground.second;
          break;
        case VideoBackground.fourth:
          newVideo = VideoBackground.third;
          break;
      }
    }

    state = state.copyWith(
      currentVideo: newVideo,
      isTransitioning: false,
    );
  }

  void nextVideo() {
    switchVideo(forward: true);
  }

  void previousVideo() {
    switchVideo(forward: false);
  }

  void selectVideo(VideoBackground video) {
    if (state.currentVideo == video) return;

    state = state.copyWith(isTransitioning: true);
    state = state.copyWith(
      currentVideo: video,
      isTransitioning: false,
    );
  }
}
