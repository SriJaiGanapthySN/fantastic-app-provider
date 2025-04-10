import 'package:fantastic_app_riverpod/widgets/chat/animated_card_message.dart';
import 'package:fantastic_app_riverpod/widgets/chat/animatedmessagebubble.dart';
import 'package:flutter/material.dart';

class MessageFactory {
  final TickerProvider vsync;

  MessageFactory(this.vsync);

  Widget createUserMessage({
    required String messageText,
    required Function onAnimationComplete,
  }) {
    AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    );

    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(-10, 80),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutQuint,
    ));

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onAnimationComplete();
      }
    });

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
    required dynamic Function() onAnimationComplete,
  }) {
    return AnimatedCardMessage(
      isQuestion: isQuestion,
      onAnimationComplete: onAnimationComplete,
    );
  }
}
