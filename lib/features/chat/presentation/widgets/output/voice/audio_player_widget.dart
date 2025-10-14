import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/features/ritual/presentation/providers/audio_player_provider.dart';

class AudioPlayerWidget extends ConsumerWidget {
  final String audioUrl;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? progressColor;
  final double? height;
  final bool autoPlay;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    this.backgroundColor,
    this.iconColor,
    this.progressColor,
    this.height = 60,
    this.autoPlay = true,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider(audioUrl));
    final audioPlayerNotifier =
        ref.read(audioPlayerProvider(audioUrl).notifier);

    if (audioPlayerState.duration == Duration.zero &&
        !audioPlayerState.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: audioPlayerState.isLoading
                ? null
                : () {
                    if (audioPlayerState.isPlaying) {
                      audioPlayerNotifier.pause();
                    } else {
                      audioPlayerNotifier.play();
                    }
                  },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor ?? Colors.blue,
                shape: BoxShape.circle,
              ),
              child: audioPlayerState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      audioPlayerState.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: progressColor ?? Colors.blue,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: progressColor ?? Colors.blue,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: audioPlayerState.position.inMilliseconds
                        .toDouble()
                        .clamp(
                            0.0,
                            audioPlayerState.duration.inMilliseconds
                                .toDouble()),
                    max: audioPlayerState.duration.inMilliseconds.toDouble(),
                    onChanged: audioPlayerState.isLoading
                        ? null
                        : (value) {
                            audioPlayerNotifier
                                .seek(Duration(milliseconds: value.round()));
                          },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audioPlayerState.position),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDuration(audioPlayerState.duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
