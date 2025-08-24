import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/utils/question_detector.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/animation_provider.dart';
import 'package:fantastic_app_riverpod/providers/speech_recognition_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';

class MessageNotifier extends StateNotifier<MessageFactory?> {
  final Ref ref;
  final TickerProvider tickerProvider;

  MessageNotifier(this.ref, this.tickerProvider) : super(null) {
    state = MessageFactory(tickerProvider);
  }

  Future<void> sendMessage(String messageText) async {
    final chatNotifier = ref.read(chatProvider.notifier);
    final isQuestion = QuestionDetector.isQuestion(messageText);

    chatNotifier.setIsQuestion(isQuestion);
    
    // Set loading state
    ref.read(chatLoadingProvider.notifier).state = true;

    if (isQuestion) {
      final scrollController = ref.read(scrollControllerProvider);
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    // Add user message to UI first
    chatNotifier.setIsSendingMessage(true);
    chatNotifier.setThresholdReached(isQuestion ? false : true);

    final userMessage = state!.createUserMessage(
      messageText: messageText,
      onAnimationComplete: () => _handleUserMessageAnimationComplete(isQuestion, messageText),
    );

    chatNotifier.addMessage(userMessage);
  }

  Future<void> _handleUserMessageAnimationComplete(bool isQuestion, String messageText) async {
    final chatNotifier = ref.read(chatProvider.notifier);
    final apiService = ref.read(chatApiServiceProvider);
    
    // Create streaming message bubble immediately
    chatNotifier.setIsUserSendingMessage(true);
    
    final streamingMessageData = state!.createStreamingMessage(
      onAnimationComplete: () {
        if (isQuestion) {
          chatNotifier.setThresholdReached(false);
        }
      },
    );

    chatNotifier.addMessage(streamingMessageData.widget);
    
    // Auto scroll to bottom when message is added
    _scrollToBottomImmediate();
    
    try {
      // Send message to API with streaming
      await apiService.sendMessageWithStreaming(
        messageText,
        (chunk) {
          // Add chunk to streaming message through controller
          streamingMessageData.controller.addChunk(chunk);
          
          // Auto scroll with each chunk - use immediate version
          _scrollToBottomImmediate();
        },
        () {
          // Mark streaming as complete
          streamingMessageData.controller.completeStreaming();
          
          // Clear loading state
          ref.read(chatLoadingProvider.notifier).state = false;
          
          // Continue with existing UI logic
          Future.delayed(Duration(milliseconds: 1000), () {
            chatNotifier.setIsQuestion(false);
            chatNotifier.setIsSendingMessage(false);
          });
          
          // Final scroll to bottom
          _scrollToBottom();
          
          // Clean up controller
          streamingMessageData.controller.dispose();
        },
      );
    } catch (e) {
      print('Error sending message: $e');
      streamingMessageData.controller.addChunk('Sorry, I encountered an error. Please try again.');
      streamingMessageData.controller.completeStreaming();
      
      // Clear loading state
      ref.read(chatLoadingProvider.notifier).state = false;
      
      Future.delayed(Duration(milliseconds: 1000), () {
        chatNotifier.setIsQuestion(false);
        chatNotifier.setIsSendingMessage(false);
      });
      
      // Clean up controller
      streamingMessageData.controller.dispose();
    }
  }

  void _scrollToBottom() {
    final chatState = ref.read(chatProvider);
    final scrollController = ref.read(scrollControllerProvider);

    if (!chatState.shouldAutoScroll && chatState.userIsScrolling) return;

    if (scrollController.hasClients) {
      // Use a shorter duration for smoother streaming scroll
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  // Enhanced scroll method for streaming with immediate effect
  void _scrollToBottomImmediate() {
    final scrollController = ref.read(scrollControllerProvider);
    
    if (scrollController.hasClients) {
      // Add a small delay to ensure the widget has been laid out
      Future.delayed(Duration(milliseconds: 50), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }
}

final messageProvider = StateNotifierProvider.family<MessageNotifier,
    MessageFactory?, TickerProvider>((ref, tickerProvider) {
  return MessageNotifier(ref, tickerProvider);
});
