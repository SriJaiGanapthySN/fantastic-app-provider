import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/utils/question_detector.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';

class MessageNotifier extends StateNotifier<MessageFactory?> {
  final Ref ref;
  final TickerProvider tickerProvider;

  MessageNotifier(this.ref, this.tickerProvider) : super(null) {
    state = MessageFactory(tickerProvider);
  }

  void sendMessage(String messageText) async {
    final chatNotifier = ref.read(chatProvider.notifier);
    final isQuestion = QuestionDetector.isQuestion(messageText);

    chatNotifier.setIsQuestion(isQuestion);

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

    // Add user message
    chatNotifier.setIsSendingMessage(true);
    chatNotifier.setThresholdReached(isQuestion ? false : true);

    final userMessage = state!.createUserMessage(
      messageText: messageText,
      onAnimationComplete: () =>
          _handleUserMessageAnimationComplete(isQuestion, messageText),
    );

    chatNotifier.addMessage(userMessage);
  }

  void _handleUserMessageAnimationComplete(
      bool isQuestion, String userMessageText) async {
    final chatNotifier = ref.read(chatProvider.notifier);

    // Schedule to set sending message to false after delay
    Future.delayed(Duration(milliseconds: 6300), () {
      chatNotifier.setIsQuestion(false);
      chatNotifier.setIsSendingMessage(false);
    });

    // Add bot response with API call
    chatNotifier.setIsUserSendingMessage(true);

    // Try to get API response
    String apiResponse = "Here is a reference to the card"; // Default fallback
    try {
      final apiService = ref.read(chatApiServiceProvider);

      // Check if authenticated, if not authenticate first
      final isAuthenticated = ref.read(authStatusProvider);
      if (!isAuthenticated) {
        const defaultEmail = "string";
        const defaultPassword = "string";
        final token =
            await apiService.authenticate(defaultEmail, defaultPassword);
        if (token != null) {
          ref.read(authStatusProvider.notifier).state = true;
        }
      }

      // Send message to API
      final response = await apiService.sendMessage(userMessageText);
      if (response != null && response['ai_message_content'] != null) {
        apiResponse = response['ai_message_content'];
        print('✅ Got API response: $apiResponse');
      }
    } catch (e) {
      print('❌ API call failed, using default message: $e');
    }

    final cardMessage = state!.createCardMessage(
      isQuestion: isQuestion,
      apiResponse: apiResponse, // Pass the API response
      onAnimationComplete: () {
        if (isQuestion) {
          chatNotifier.setThresholdReached(false);
        }
      },
    );

    chatNotifier.addMessage(cardMessage);

    // Auto scroll to bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    final chatState = ref.read(chatProvider);
    final scrollController = ref.read(scrollControllerProvider);

    if (!chatState.shouldAutoScroll && chatState.userIsScrolling) return;

    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

final messageProvider = StateNotifierProvider.family<MessageNotifier,
    MessageFactory?, TickerProvider>((ref, tickerProvider) {
  return MessageNotifier(ref, tickerProvider);
});
