import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// Video State Model
class TaskRevealVideoState {
  final VideoPlayerController? controller;
  final bool isLoading;
  final bool isInitialized;
  final String? currentVideoUrl;
  final bool hasError;
  final String? errorMessage;

  TaskRevealVideoState({
    this.controller,
    this.isLoading = true,
    this.isInitialized = false,
    this.currentVideoUrl,
    this.hasError = false,
    this.errorMessage,
  });

  TaskRevealVideoState copyWith({
    VideoPlayerController? controller,
    bool? isLoading,
    bool? isInitialized,
    String? currentVideoUrl,
    bool? hasError,
    String? errorMessage,
  }) {
    return TaskRevealVideoState(
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Video State Notifier
class TaskRevealVideoNotifier extends StateNotifier<TaskRevealVideoState> {
  bool _isDisposed = false;

  TaskRevealVideoNotifier() : super(TaskRevealVideoState(isLoading: false));

  // Initialize video controller
  Future<void> initializeVideo(String videoUrl) async {
    if (_isDisposed) return;

    print('Initializing video: $videoUrl');

    if (state.currentVideoUrl == videoUrl && state.isInitialized) {
      print('Video already initialized for this URL');
      return; // Already initialized with the same URL
    }

    // Dispose previous controller if exists
    if (state.controller != null) {
      print('Disposing previous controller');
      try {
        await _safeDisposeController(state.controller!);
      } catch (e) {
        print('Error disposing previous controller: $e');
      }
    }

    if (_isDisposed) return;

    print('Setting loading state');
    state = state.copyWith(
      isLoading: true,
      isInitialized: false,
      hasError: false,
      errorMessage: null,
      currentVideoUrl: videoUrl,
      controller: null,
    );

    try {
      print('Creating video controller');
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      if (_isDisposed) {
        controller.dispose();
        return;
      }

      print('Initializing controller...');
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

      print('Setting looping and playing');
      await controller.setLooping(true);

      // Add error listener before playing
      controller.addListener(() {
        if (!_isDisposed && controller.value.hasError && mounted) {
          print('Video error: ${controller.value.errorDescription}');
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

      print('Video initialized successfully');
      state = state.copyWith(
        controller: controller,
        isLoading: false,
        isInitialized: true,
        hasError: false,
      );
    } catch (e) {
      print('Error initializing video: $e');
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
      print('Error in safe dispose: $e');
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
        print('Error pausing video: $e');
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
        print('Error resuming video: $e');
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
final taskRevealVideoProvider =
    StateNotifierProvider<TaskRevealVideoNotifier, TaskRevealVideoState>((ref) {
  return TaskRevealVideoNotifier();
});
