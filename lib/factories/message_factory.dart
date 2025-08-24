import 'package:fantastic_app_riverpod/widgets/chat/animated_card_message.dart';
import 'package:fantastic_app_riverpod/widgets/chat/animatedmessagebubble.dart';
import 'package:fantastic_app_riverpod/widgets/chat/streaming_message_bubble.dart';
import 'package:fantastic_app_riverpod/controllers/streaming_message_controller.dart';
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

  Widget createAiMessage({
    required String messageText,
    required bool isQuestion,
    required Function onAnimationComplete,
  }) {
    AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    );

    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(10, 80),
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
      alignment: Alignment.centerLeft,
      animation: slideAnimation,
      controller: animationController,
      bubbleColor: Colors.blue.shade100,
      textColor: Colors.black87,
    );
  }

  StreamingMessageData createStreamingMessage({
    required Function onAnimationComplete,
  }) {
    AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800), // Similar speed to user message
    );

    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(10, 80),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutQuint, // Same curve as user message
    ));

    animationController.forward();

    final streamingController = StreamingMessageController();

    final widget = StreamingMessageBubble(
      animation: slideAnimation,
      controller: animationController,
      alignment: Alignment.centerLeft,
      bubbleColor: Colors.blue.shade100, // More translucent in the widget
      textColor: Colors.black87,
      onAnimationComplete: onAnimationComplete,
      streamingController: streamingController,
    );

    return StreamingMessageData(
      widget: widget,
      controller: streamingController,
    );
  }
}

class StreamingMessageData {
  final StreamingMessageBubble widget;
  final StreamingMessageController controller;

  StreamingMessageData({
    required this.widget,
    required this.controller,
  });
}
