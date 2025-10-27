import 'package:fantastic_app_riverpod/features/chat/presentation/providers/animation/animated_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:fantastic_app_riverpod/features/chat/presentation/widgets/output/voice/audio_player_widget.dart';

class AudioMessageBubble extends ConsumerWidget {
  final String id;
  final String message;
  final String audioUrl;
  final Alignment alignment;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;
  final Color bubbleColor;
  final Color textColor;
  final Color? audioBackgroundColor;
  final Color? audioIconColor;
  final Color? audioProgressColor;

  const AudioMessageBubble({
    super.key,
    required this.id,
    required this.message,
    required this.audioUrl,
    required this.alignment,
    required this.shouldAnimate,
    this.onAnimationComplete,
    required this.bubbleColor,
    required this.textColor,
    this.audioBackgroundColor,
    this.audioIconColor,
    this.audioProgressColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerArgs = AnimatedCardProviderArgs(
      id: id,
      shouldAnimate: shouldAnimate,
      onAnimationComplete: onAnimationComplete,
    );
    final animationState = ref.watch(animatedCardProvider(providerArgs));
    final maxWidth = MediaQuery.of(context).size.width * 0.8;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The main content (bubble and audio player)
              AnimatedOpacity(
                opacity: animationState.isContentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: _buildMessageContent(context),
              ),
              // The sparkle animation
              if (animationState.showSparkle)
                Lottie.asset(
                  'assets/animations/All Lottie/Glowing Star/Image Preload Gradient.json',
                  width: maxWidth * 0.85,
                  height: 160,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(20),
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
                height: 1.4,
                fontSize: 16,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: true,
                applyHeightToLastDescent: true,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 14),
          ],

          // Audio Player
          AudioPlayerWidget(
            audioUrl: audioUrl,
            backgroundColor:
                audioBackgroundColor ?? Colors.white.withOpacity(0.9),
            iconColor: audioIconColor ?? Colors.blue,
            progressColor: audioProgressColor ?? Colors.blue,
            height: 75,
          ),

          // Audio indicator row (always show)
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.audiotrack,
                size: 16,
                color: textColor.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                message.isEmpty ? 'Voice Response' : 'Audio Response',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
