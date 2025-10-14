import 'package:fantastic_app_riverpod/features/chat/presentation/widgets/output/card/animated_card_message.dart';
import 'package:fantastic_app_riverpod/features/chat/presentation/widgets/input/text/animatedmessagebubble.dart';
import 'package:fantastic_app_riverpod/features/chat/presentation/widgets/output/text/animated_object_card_message.dart';
import 'package:fantastic_app_riverpod/features/chat/presentation/widgets/input/voice/audio_message_bubble.dart';
import 'package:flutter/material.dart';

class MessageFactory {
  final TickerProvider vsync;

  MessageFactory(this.vsync);

  Widget createUserMessage({
    required String messageText,
    required Function onAnimationComplete,
    bool shouldAnimate = true, // Add flag to control animation
  }) {
    AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    );

    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: shouldAnimate ? const Offset(-0.2, 0.2) : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutQuint,
    ));

    if (shouldAnimate) {
      animationController.forward();

      animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          onAnimationComplete();
        }
      });
    } else {
      // For existing messages, complete immediately without animation
      onAnimationComplete();
    }

    return AnimatedMessageBubble(
      message: messageText,
      alignment: Alignment.centerRight,
      animation: slideAnimation,
      controller: animationController,
      bubbleColor: Colors.white,
      textColor: Colors.black,
    );
  }

  Widget createCardMessage({
    required String id,
    required bool isQuestion,
    String? apiResponse,
    required dynamic Function() onAnimationComplete,
    bool shouldAnimate = true, // Add flag to control animation
  }) {
    return AnimatedCardMessage(
      id: id,
      isQuestion: isQuestion,
      apiResponse: apiResponse ?? "Here is a reference to the card",
      onAnimationComplete: onAnimationComplete,
      shouldAnimate: shouldAnimate, // Pass animation flag
    );
  }

  Widget createAnimatedObjectCardMessage({
    required String id,
    required Function() onAnimationComplete,
    bool shouldAnimate = true,
  }) {
    if (!shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onAnimationComplete();
      });
    }
    return AnimatedObjectCardMessage(
      onAnimationComplete: shouldAnimate ? onAnimationComplete : null,
    );
  }

  Widget createAudioMessage({
    required String id,
    required String messageText,
    required String audioUrl,
    required VoidCallback onAnimationComplete,
    bool isUser = false,
    bool shouldAnimate = true, // Add flag to control animation
  }) {
    return AudioMessageBubble(
      id: id,
      message: messageText,
      audioUrl: audioUrl,
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      shouldAnimate: shouldAnimate,
      onAnimationComplete: onAnimationComplete,
      bubbleColor: isUser ? Colors.white : Colors.blue[50]!,
      textColor: isUser ? Colors.black : Colors.blue[900]!,
      audioIconColor: isUser ? Colors.blue : Colors.blue[700],
      audioProgressColor: isUser ? Colors.blue : Colors.blue[700],
    );
  }

  Widget createContentCardMessage({
    required String objectId,
    required String type,
    required VoidCallback onAnimationComplete,
    bool shouldAnimate = true,
  }) {
    // Create a descriptive message for the content card
    String cardText = 'Here\'s the ${type.toLowerCase()} you requested:';

    return AnimatedCardMessage(
      id: objectId,
      isQuestion: false,
      apiResponse: cardText,
      onAnimationComplete: onAnimationComplete,
      shouldAnimate: shouldAnimate,
    );
  }
}
