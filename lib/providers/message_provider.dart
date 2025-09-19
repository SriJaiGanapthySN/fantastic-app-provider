import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/utils/question_detector.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';

class MessageNotifier extends StateNotifier<MessageFactory?> {
  final Ref ref;
  final TickerProvider tickerProvider;

  MessageNotifier(this.ref, this.tickerProvider) : super(null) {
    state = MessageFactory(tickerProvider);
  }

  void sendMessage(String messageText, {String inputType = 'text'}) async {
    final chatNotifier = ref.read(chatProvider.notifier);

    // Check for test audio command
    if (messageText.toLowerCase().contains('test audio')) {
      addTestAudioMessage();
      return;
    }

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

    // Create message data instead of widget
    final userMessageData = ChatMessageData(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_user',
      text: messageText,
      type: ChatMessageType.userMessage,
      isUser: true,
      timestamp: DateTime.now(),
      hasAnimated: false, // New message should animate
    );

    // Add to message data
    chatNotifier.addMessageData(userMessageData);

    // Trigger API call after a delay to allow animation
    Future.delayed(Duration(milliseconds: 500), () {
      _handleUserMessageAnimationComplete(isQuestion, messageText, inputType);
    });
  }

  // Method to add existing messages without animation (for when returning to chat)
  void addExistingMessage(Widget message) {
    final chatNotifier = ref.read(chatProvider.notifier);
    chatNotifier.addMessage(message);
  }

  // Create message without animation for existing content
  Widget createExistingUserMessage(String messageText) {
    return state!.createUserMessage(
      messageText: messageText,
      shouldAnimate: false, // Existing messages should not animate
      onAnimationComplete: () {}, // No animation completion needed
    );
  }

  Widget createExistingCardMessage(bool isQuestion, String apiResponse) {
    return state!.createCardMessage(
      isQuestion: isQuestion,
      apiResponse: apiResponse,
      shouldAnimate: false, // Existing messages should not animate
      onAnimationComplete: () {}, // No animation completion needed
    );
  }

  Widget createExistingAudioMessage(String messageText, String audioUrl,
      {bool isUser = false}) {
    return state!.createAudioMessage(
      messageText: messageText,
      audioUrl: audioUrl,
      isUser: isUser,
      shouldAnimate: false, // Existing messages should not animate
      onAnimationComplete: () {}, // No animation completion needed
    );
  }

  void _handleUserMessageAnimationComplete(
      bool isQuestion, String userMessageText, String inputType) async {
    final chatNotifier = ref.read(chatProvider.notifier);

    // Schedule to set sending message to false after delay
    Future.delayed(Duration(milliseconds: 6300), () {
      chatNotifier.setIsQuestion(false);
      chatNotifier.setIsSendingMessage(false);
    });

    // Add bot response with API call
    chatNotifier.setIsUserSendingMessage(true);

    // Try to get API response with streaming
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

      // No placeholder messages - wait for API response to create appropriate message type

      // Now use streaming based on input type
      String fullResponse = "";
      final response = await apiService.sendMessageWithStreaming(
        userMessageText,
        (chunk) {
          // Update the streaming text in the card message
          fullResponse += chunk;
          // Note: In a real implementation, you'd need to update the card message content
          // For now, we'll collect the full response and handle differently based on input type
        },
        () async {
          // Streaming complete - handle based on input type
          if (fullResponse.isNotEmpty) {
            apiResponse = fullResponse;
            print('✅ Got streamed API response: $apiResponse');

            // Create different message types based on input type (no placeholder removal needed)
            if (inputType == 'voice') {
              // For voice input - create audio-only message data
              final audioMessageData = ChatMessageData(
                id: DateTime.now().millisecondsSinceEpoch.toString() + '_audio',
                text: "", // Empty text for audio-only
                type: ChatMessageType.audioMessage,
                isUser: false,
                audioUrl: apiService.getAudioUrl(apiResponse),
                timestamp: DateTime.now(),
                hasAnimated: false, // New message should animate
              );
              chatNotifier.addMessageData(audioMessageData);
            } else {
              // For text input - create text-only card message data
              final cardMessageData = ChatMessageData(
                id: DateTime.now().millisecondsSinceEpoch.toString() + '_card',
                text: apiResponse,
                type: ChatMessageType.cardMessage,
                isUser: false,
                isQuestion: isQuestion,
                timestamp: DateTime.now(),
                hasAnimated: false, // New message should animate
              );
              chatNotifier.addMessageData(cardMessageData);
            }

            _scrollToBottom();
          }
        },
        inputType: inputType,
      );

      // If streaming failed, fall back to regular response
      if (response == null && fullResponse.isEmpty) {
        final regularResponse =
            await apiService.sendMessage(userMessageText, inputType: inputType);
        if (regularResponse != null &&
            regularResponse['ai_message_content'] != null) {
          apiResponse = regularResponse['ai_message_content'];

          // Create appropriate message type based on input type (no placeholder removal needed)
          if (inputType == 'voice') {
            // For voice input - create audio-only message data
            final audioMessageData = ChatMessageData(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  '_audio_fallback',
              text: "", // Empty text for audio-only
              type: ChatMessageType.audioMessage,
              isUser: false,
              audioUrl: apiService.getAudioUrl(apiResponse),
              timestamp: DateTime.now(),
              hasAnimated: false, // New message should animate
            );
            chatNotifier.addMessageData(audioMessageData);
          } else {
            // For text input - create text-only card message data
            final cardMessageData = ChatMessageData(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  '_card_fallback',
              text: apiResponse,
              type: ChatMessageType.cardMessage,
              isUser: false,
              isQuestion: isQuestion,
              timestamp: DateTime.now(),
              hasAnimated: false, // New message should animate
            );
            chatNotifier.addMessageData(cardMessageData);
          }

          _scrollToBottom();
          return;
        }
      }
    } catch (e) {
      print('❌ API call failed, using default message: $e');

      // If everything fails, just show a regular card message (no placeholder removal needed)
      final errorMessageData = ChatMessageData(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_error',
        text: apiResponse, // Default fallback
        type: ChatMessageType.cardMessage,
        isUser: false,
        isQuestion: isQuestion,
        timestamp: DateTime.now(),
        hasAnimated: false, // New message should animate
      );
      chatNotifier.addMessageData(errorMessageData);
      _scrollToBottom();
    }
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

  // Helper method to convert message types
  ChatMessageType _getMessageType(String type) {
    switch (type) {
      case 'audio':
        return ChatMessageType.audioMessage;
      case 'card':
      default:
        return ChatMessageType.cardMessage;
    }
  }

  // Helper method to convert old widgets to message data (for migration)
  ChatMessageData _convertToMessageData(
    Widget widget,
    String type,
    String text,
    bool isUser,
    bool isQuestion,
    DateTime timestamp, {
    bool shouldAnimate = true,
  }) {
    return ChatMessageData(
      id: timestamp.millisecondsSinceEpoch.toString(),
      text: text,
      type: _getMessageType(type),
      isUser: isUser,
      isQuestion: isQuestion,
      timestamp: timestamp,
      hasAnimated:
          !shouldAnimate, // If shouldAnimate is false, mark as already animated
    );
  }

  // Test method to add an audio message for demonstration
  void addTestAudioMessage() {
    final chatNotifier = ref.read(chatProvider.notifier);
    final apiService = ref.read(chatApiServiceProvider);

    const testText =
        "Here's your audio response! This audio player allows you to play, pause, and seek through the audio content.";

    final audioMessage = state!.createAudioMessage(
      messageText: testText,
      audioUrl: apiService.getAudioUrl(testText),
      shouldAnimate: true, // Test messages should animate
      onAnimationComplete: () {
        print('🎵 Test audio message animation completed');
      },
      isUser: false,
    );

    chatNotifier.addMessage(audioMessage);
    _scrollToBottom();
  }
}

final messageProvider = StateNotifierProvider.family<MessageNotifier,
    MessageFactory?, TickerProvider>((ref, tickerProvider) {
  return MessageNotifier(ref, tickerProvider);
});
