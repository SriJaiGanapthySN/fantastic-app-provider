import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

// 1. Define the State
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration duration;
  final Duration position;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? duration,
    Duration? position,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}

// 2. Define the Notifier
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final String audioUrl;
  final bool autoPlay;
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  AudioPlayerNotifier({required this.audioUrl, this.autoPlay = true})
      : super(const AudioPlayerState()) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    state = state.copyWith(isLoading: true);

    try {
      _playerStateSubscription =
          _audioPlayer.playerStateStream.listen((playerState) {
        if (mounted) {
          state = state.copyWith(
            isPlaying: playerState.playing,
            isLoading: playerState.processingState == ProcessingState.loading ||
                playerState.processingState == ProcessingState.buffering,
          );
        }
      });

      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          state = state.copyWith(duration: duration);
        }
      });

      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          state = state.copyWith(position: position);
        }
      });

      await _audioPlayer.setUrl(audioUrl);

      final duration = await _audioPlayer.durationStream.first;
      if (mounted && (duration == null || duration == Duration.zero)) {
        print('Audio has zero duration. Not playing.');
        state = state.copyWith(isLoading: false, duration: Duration.zero);
        return;
      }

      state = state.copyWith(isLoading: false);

      if (autoPlay) {
        await play();
      }
    } catch (e) {
      print('Error loading audio: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// 3. Define the Provider
final audioPlayerProvider = StateNotifierProvider.autoDispose
    .family<AudioPlayerNotifier, AudioPlayerState, String>((ref, audioUrl) {
  return AudioPlayerNotifier(audioUrl: audioUrl);
});
