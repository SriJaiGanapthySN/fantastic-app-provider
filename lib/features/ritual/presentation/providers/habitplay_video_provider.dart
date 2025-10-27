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
  final int retryCount;

  HabitPlayVideoState({
    this.controller,
    this.isLoading = true,
    this.isInitialized = false,
    this.currentVideoUrl,
    this.hasError = false,
    this.errorMessage,
    this.retryCount = 0,
  });

  HabitPlayVideoState copyWith({
    VideoPlayerController? controller,
    bool? isLoading,
    bool? isInitialized,
    String? currentVideoUrl,
    bool? hasError,
    String? errorMessage,
    int? retryCount,
  }) {
    return HabitPlayVideoState(
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

// Video State Notifier for HabitPlay
class HabitPlayVideoNotifier extends StateNotifier<HabitPlayVideoState> {
  bool _isDisposed = false;
  static const int maxRetries = 2;

  HabitPlayVideoNotifier() : super(HabitPlayVideoState(isLoading: false));

  // Initialize video controller
  Future<void> initializeVideo(String videoUrl, {bool isRetry = false}) async {
    if (_isDisposed) return;

    // Reset retry count for new videos
    if (!isRetry && state.currentVideoUrl != videoUrl) {
      state = state.copyWith(retryCount: 0);
    }

    print(
        'HabitPlay: Initializing video: $videoUrl (retry: $isRetry, count: ${state.retryCount})');

    if (state.currentVideoUrl == videoUrl && state.isInitialized && !isRetry) {
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
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

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

      print('HabitPlay: Setting looping and volume');
      await controller.setLooping(true);
      // Set volume to avoid audio issues that can cause ExoPlayer errors
      await controller.setVolume(1.0);

      // Add error listener with retry mechanism
      controller.addListener(() {
        if (!_isDisposed && controller.value.hasError && mounted) {
          final errorDescription =
              controller.value.errorDescription ?? 'Unknown video error';
          print('HabitPlay: Video error: $errorDescription');

          // Attempt retry if under max retries
          if (state.retryCount < maxRetries) {
            print(
                'HabitPlay: Attempting retry ${state.retryCount + 1}/$maxRetries');
            if (!_isDisposed) {
              state = state.copyWith(
                retryCount: state.retryCount + 1,
              );
              // Retry after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                if (!_isDisposed) {
                  initializeVideo(videoUrl, isRetry: true);
                }
              });
            }
          } else {
            // Max retries exceeded, show error
            print('HabitPlay: Max retries exceeded, showing error');
            if (!_isDisposed) {
              state = state.copyWith(
                hasError: true,
                errorMessage: errorDescription,
                isLoading: false,
                isInitialized: false,
              );
            }
          }
        }
      });

      // Small delay before playing to ensure initialization is complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (_isDisposed) {
        controller.dispose();
        return;
      }

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

      // Attempt retry if under max retries
      if (state.retryCount < maxRetries && !_isDisposed) {
        print(
            'HabitPlay: Attempting retry ${state.retryCount + 1}/$maxRetries after exception');
        state = state.copyWith(
          retryCount: state.retryCount + 1,
        );
        // Retry after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (!_isDisposed) {
          await initializeVideo(videoUrl, isRetry: true);
        }
      } else {
        // Max retries exceeded or disposed, show error
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
