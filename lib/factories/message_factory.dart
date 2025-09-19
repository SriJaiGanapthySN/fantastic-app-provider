import 'package:fantastic_app_riverpod/widgets/chat/animated_card_message.dart';
import 'package:fantastic_app_riverpod/widgets/chat/animatedmessagebubble.dart';
import 'package:fantastic_app_riverpod/widgets/chat/audio_message_bubble.dart';
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
      begin: shouldAnimate ? const Offset(-10, 80) : Offset.zero,
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
    required bool isQuestion,
    String? apiResponse,
    required dynamic Function() onAnimationComplete,
    bool shouldAnimate = true, // Add flag to control animation
  }) {
    return AnimatedCardMessage(
      isQuestion: isQuestion,
      apiResponse: apiResponse ?? "Here is a reference to the card",
      onAnimationComplete: onAnimationComplete,
      shouldAnimate: shouldAnimate, // Pass animation flag
    );
  }

  Widget createAudioMessage({
    required String messageText,
    required String audioUrl,
    required Function onAnimationComplete,
    bool isUser = false,
    bool shouldAnimate = true, // Add flag to control animation
  }) {
    AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2), // Increased from 1 to 2 seconds
    );

    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: shouldAnimate
          ? (isUser ? const Offset(10, 80) : const Offset(-10, 80))
          : Offset.zero,
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

    return AudioMessageBubble(
      message: messageText,
      audioUrl: audioUrl,
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      animation: slideAnimation,
      controller: animationController,
      bubbleColor: isUser ? Colors.white : Colors.blue[50]!,
      textColor: isUser ? Colors.black : Colors.blue[900]!,
      audioIconColor: isUser ? Colors.blue : Colors.blue[700],
      audioProgressColor: isUser ? Colors.blue : Colors.blue[700],
    );
  }
}
