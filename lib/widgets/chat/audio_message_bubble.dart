import 'package:flutter/material.dart';
import 'package:fantastic_app_riverpod/widgets/chat/audio_player_widget.dart';

class AudioMessageBubble extends StatelessWidget {
  final String message;
  final String audioUrl;
  final Alignment alignment;
  final Animation<Offset> animation;
  final AnimationController controller;
  final Color bubbleColor;
  final Color textColor;
  final Color? audioBackgroundColor;
  final Color? audioIconColor;
  final Color? audioProgressColor;

  const AudioMessageBubble({
    super.key,
    required this.message,
    required this.audioUrl,
    required this.alignment,
    required this.animation,
    required this.controller,
    required this.bubbleColor,
    required this.textColor,
    this.audioBackgroundColor,
    this.audioIconColor,
    this.audioProgressColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return SlideTransition(
      position: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text content (only show if message is not empty)
                  if (message.isNotEmpty) ...[
                    Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        height: 1.25,
                        fontSize: 16,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: true,
                        applyHeightToLastDescent: true,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Audio Player
                  AudioPlayerWidget(
                    audioUrl: audioUrl,
                    backgroundColor:
                        audioBackgroundColor ?? Colors.white.withOpacity(0.9),
                    iconColor: audioIconColor ?? Colors.blue,
                    progressColor: audioProgressColor ?? Colors.blue,
                    height: 70,
                  ),

                  // Audio indicator row (always show)
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.audiotrack,
                        size: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.isEmpty ? 'Voice Response' : 'Audio Response',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
