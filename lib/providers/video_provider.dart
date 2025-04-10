import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VideoBackground { morning, afternoon, evening, night }

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
  Timer? _timeCheckTimer;

  VideoNotifier() : super(VideoState(currentVideo: _getTimeBasedBackground())) {
    // Check for time changes every minute
    _timeCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateBackgroundBasedOnTime();
    });
  }

  @override
  void dispose() {
    _timeCheckTimer?.cancel();
    super.dispose();
  }

  static VideoBackground _getTimeBasedBackground() {
    final hour = DateTime.now().hour;

    // 5:00 AM - 11:59 AM: Morning
    if (hour >= 5 && hour < 12) {
      return VideoBackground.morning;
    }
    // 12:00 PM - 4:59 PM: Afternoon
    else if (hour >= 12 && hour < 18) {
      return VideoBackground.afternoon;
    }
    // 5:00 PM - 8:59 PM: Evening
    else if (hour >= 18 && hour < 21) {
      return VideoBackground.evening;
    }
    // 9:00 PM - 4:59 AM: Night
    else {
      return VideoBackground.night;
    }
  }

  void _updateBackgroundBasedOnTime() {
    final timeBasedBackground = _getTimeBasedBackground();

    // Only update if the time period has changed
    if (state.currentVideo != timeBasedBackground) {
      state = state.copyWith(isTransitioning: true);
      state = state.copyWith(
        currentVideo: timeBasedBackground,
        isTransitioning: false,
      );
    }
  }

  // Keep these methods for manual control if needed
  void nextVideo() {
    switchVideo(forward: true);
  }

  void previousVideo() {
    switchVideo(forward: false);
  }

  void switchVideo({bool forward = true}) {
    state = state.copyWith(isTransitioning: true);

    VideoBackground newVideo;
    if (forward) {
      switch (state.currentVideo) {
        case VideoBackground.morning:
          newVideo = VideoBackground.afternoon;
          break;
        case VideoBackground.afternoon:
          newVideo = VideoBackground.evening;
          break;
        case VideoBackground.evening:
          newVideo = VideoBackground.night;
          break;
        case VideoBackground.night:
          newVideo = VideoBackground.morning;
          break;
      }
    } else {
      switch (state.currentVideo) {
        case VideoBackground.morning:
          newVideo = VideoBackground.night;
          break;
        case VideoBackground.afternoon:
          newVideo = VideoBackground.morning;
          break;
        case VideoBackground.evening:
          newVideo = VideoBackground.afternoon;
          break;
        case VideoBackground.night:
          newVideo = VideoBackground.evening;
          break;
      }
    }

    state = state.copyWith(
      currentVideo: newVideo,
      isTransitioning: false,
    );
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

// Add a provider for VideoNotifier
final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  return VideoNotifier();
});
