import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// Video State Model for HabitPlay
class HabitPlayVideoState {
  final VideoPlayerController? controller;
  final bool isLoading;
  final bool isInitialized;
  final String? currentVideoUrl;
  final bool hasError;
  final String? errorMessage;

  HabitPlayVideoState({
    this.controller,
    this.isLoading = true,
    this.isInitialized = false,
    this.currentVideoUrl,
    this.hasError = false,
    this.errorMessage,
  });

  HabitPlayVideoState copyWith({
    VideoPlayerController? controller,
    bool? isLoading,
    bool? isInitialized,
    String? currentVideoUrl,
    bool? hasError,
    String? errorMessage,
  }) {
    return HabitPlayVideoState(
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Video State Notifier for HabitPlay
class HabitPlayVideoNotifier extends StateNotifier<HabitPlayVideoState> {
  bool _isDisposed = false;

  HabitPlayVideoNotifier() : super(HabitPlayVideoState(isLoading: false));

  // Initialize video controller
  Future<void> initializeVideo(String videoUrl) async {
    if (_isDisposed) return;

    print('HabitPlay: Initializing video: $videoUrl');

    if (state.currentVideoUrl == videoUrl && state.isInitialized) {
      print('HabitPlay: Video already initialized for this URL');
      return; // Already initialized with the same URL
    }

    // Dispose previous controller if exists
    if (state.controller != null) {
      print('HabitPlay: Disposing previous controller');
      try {
        await _safeDisposeController(state.controller!);
      } catch (e) {
        print('HabitPlay: Error disposing previous controller: $e');
      }
    }

    if (_isDisposed) return;

    print('HabitPlay: Setting loading state');
    state = state.copyWith(
      isLoading: true,
      isInitialized: false,
      hasError: false,
      errorMessage: null,
      currentVideoUrl: videoUrl,
      controller: null,
    );

    try {
      print('HabitPlay: Creating video controller');
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      if (_isDisposed) {
        controller.dispose();
        return;
      }

      print('HabitPlay: Initializing controller...');
      // Add timeout to prevent infinite loading
      await controller.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timeout after 30 seconds');
        },
      );

      if (_isDisposed) {
        controller.dispose();
        return;
      }

      print('HabitPlay: Setting looping and playing');
      await controller.setLooping(true);

      // Add error listener before playing
      controller.addListener(() {
        if (!_isDisposed && controller.value.hasError && mounted) {
          print('HabitPlay: Video error: ${controller.value.errorDescription}');
          if (!_isDisposed) {
            state = state.copyWith(
              hasError: true,
              errorMessage: controller.value.errorDescription,
              isLoading: false,
              isInitialized: false,
            );
          }
        }
      });

      await controller.play();

      if (_isDisposed) {
        controller.dispose();
        return;
      }

      print('HabitPlay: Video initialized successfully');
      state = state.copyWith(
        controller: controller,
        isLoading: false,
        isInitialized: true,
        hasError: false,
      );
    } catch (e) {
      print('HabitPlay: Error initializing video: $e');
      if (!_isDisposed) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: false,
          hasError: true,
          errorMessage: e.toString(),
        );
      }
    }
  }

  // Safe controller disposal
  Future<void> _safeDisposeController(VideoPlayerController controller) async {
    try {
      // Remove all listeners first
      controller.removeListener(() {});

      // Pause before disposing
      if (controller.value.isInitialized) {
        await controller.pause();
      }

      // Small delay to ensure all operations complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Dispose the controller
      await controller.dispose();
    } catch (e) {
      print('HabitPlay: Error in safe dispose: $e');
    }
  }

  // Pause video
  void pauseVideo() {
    if (!_isDisposed &&
        state.controller != null &&
        state.controller!.value.isInitialized) {
      try {
        state.controller!.pause();
      } catch (e) {
        print('HabitPlay: Error pausing video: $e');
      }
    }
  }

  // Resume video
  void resumeVideo() {
    if (!_isDisposed &&
        state.controller != null &&
        state.controller!.value.isInitialized) {
      try {
        state.controller!.play();
      } catch (e) {
        print('HabitPlay: Error resuming video: $e');
      }
    }
  }

  // Dispose video controller
  @override
  void dispose() {
    _isDisposed = true;
    if (state.controller != null) {
      _safeDisposeController(state.controller!);
    }
    super.dispose();
  }
}

// Provider
final habitPlayVideoProvider =
    StateNotifierProvider<HabitPlayVideoNotifier, HabitPlayVideoState>((ref) {
  return HabitPlayVideoNotifier();
});
