import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/utils/question_detector.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';
import 'package:fantastic_app_riverpod/services/token_service.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';
import 'package:fantastic_app_riverpod/widgets/chat/animated_object_card_message.dart';

class MessageNotifier extends StateNotifier<MessageFactory?> {
  final Ref ref;
  final TickerProvider tickerProvider;

  MessageNotifier(this.ref, this.tickerProvider) : super(null) {
    state = MessageFactory(tickerProvider);
  }

  void sendMessage(String messageText, {String inputType = 'text'}) async {
    print('sendMessage called with inputType: $inputType');
    print('messageText: $messageText');

    final chatNotifier = ref.read(chatProvider.notifier);

    // Check for special keywords to show animated object card
    final lowerCaseMessage = messageText.toLowerCase().trim();
    if (lowerCaseMessage == 'challenge' ||
        lowerCaseMessage == 'journey' ||
        lowerCaseMessage == 'skilltrack') {
      // Add user message
      final userMessageData = ChatMessageData(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_user',
        text: messageText,
        type: ChatMessageType.userMessage,
        isUser: true,
        timestamp: DateTime.now(),
        hasAnimated: false,
      );
      chatNotifier.addMessageData(userMessageData);

      // Add animated object card response
      final animatedObjectCardData = ChatMessageData(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_object_card',
        text: '',
        type: ChatMessageType.animatedObjectCard,
        isUser: false,
        timestamp: DateTime.now(),
        hasAnimated: false,
      );
      chatNotifier.addMessageData(animatedObjectCardData);
      _scrollToBottom();
      return;
    }

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
    chatNotifier.setThresholdReached(true); // Always show thinking animation

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

  Widget createExistingCardMessage(
      String id, bool isQuestion, String apiResponse) {
    return state!.createCardMessage(
      id: id,
      isQuestion: isQuestion,
      apiResponse: apiResponse,
      shouldAnimate: false, // Existing messages should not animate
      onAnimationComplete: () {}, // No animation completion needed
    );
  }

  Widget createExistingAudioMessage(
      String id, String messageText, String audioUrl,
      {bool isUser = false}) {
    return state!.createAudioMessage(
      id: id,
      messageText: messageText,
      audioUrl: audioUrl,
      isUser: isUser,
      shouldAnimate: false, // Existing messages should not animate
      onAnimationComplete: () {}, // No animation completion needed
    );
  }

  void _handleUserMessageAnimationComplete(
      bool isQuestion, String userMessageText, String inputType) async {
    print(
        '_handleUserMessageAnimationComplete called with inputType: $inputType');

    final chatNotifier = ref.read(chatProvider.notifier);
    final apiService =
        ref.read(chatApiServiceProvider); // Move this outside try block

    try {
      // Check if authenticated using token service
      final isAuthenticated = await TokenService.isAuthenticated();
      if (!isAuthenticated) {
        print('User not authenticated. Chat requires authentication.');
        // Turn off thinking animation
        chatNotifier.setThresholdReached(false);
        chatNotifier.setIsSendingMessage(false);
        return;
      }

      // For voice input, we want the text response first, so we call the text endpoint.
      final apiInputType = inputType == 'voice' ? 'text' : inputType;
      print('Calling API with inputType: $apiInputType');

      // Now use streaming based on input type
      String fullResponse = "";
      final response = await apiService.sendMessageWithStreaming(
        userMessageText,
        (chunk) {
          fullResponse += chunk;
        },
        () async {
          // Streaming complete
          print(
              'Streaming complete, handling original inputType: $inputType');
          if (fullResponse.isNotEmpty) {
            // Create different message types based on input type
            if (inputType == 'voice') {
              final audioMessageData = ChatMessageData(
                id: DateTime.now().millisecondsSinceEpoch.toString() + '_audio',
                text: "",
                type: ChatMessageType.audioMessage,
                isUser: false,
                audioUrl: apiService.getAudioUrl(fullResponse),
                timestamp: DateTime.now(),
                hasAnimated: false,
              );
              chatNotifier.addMessageData(audioMessageData);
            } else {
              final cardMessageData = ChatMessageData(
                id: DateTime.now().millisecondsSinceEpoch.toString() + '_card',
                text: fullResponse,
                type: ChatMessageType.cardMessage,
                isUser: false,
                isQuestion: isQuestion,
                timestamp: DateTime.now(),
                hasAnimated: false,
              );
              chatNotifier.addMessageData(cardMessageData);
            }
            _scrollToBottom();
          }
          // Turn off thinking animation
          chatNotifier.setThresholdReached(false);
          chatNotifier.setIsSendingMessage(false);
        },
        inputType: apiInputType,
      );

      // If streaming failed, fall back to regular response
      if (response == null && fullResponse.isEmpty) {
        print(
            'Streaming failed, falling back to regular API call with inputType: $apiInputType');
        final regularResponse = await apiService.sendMessage(userMessageText,
            inputType: apiInputType);
        if (regularResponse != null &&
            regularResponse['ai_message_content'] != null) {
          final apiResponse = regularResponse['ai_message_content'];

          if (inputType == 'voice') {
            if (apiResponse.isNotEmpty) {
              final audioMessageData = ChatMessageData(
                id: DateTime.now().millisecondsSinceEpoch.toString() +
                    '_audio_fallback',
                text: "",
                type: ChatMessageType.audioMessage,
                isUser: false,
                audioUrl: apiService.getAudioUrl(apiResponse),
                timestamp: DateTime.now(),
                hasAnimated: false,
              );
              chatNotifier.addMessageData(audioMessageData);
            }
          } else {
            final cardMessageData = ChatMessageData(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  '_card_fallback',
              text: apiResponse,
              type: ChatMessageType.cardMessage,
              isUser: false,
              isQuestion: isQuestion,
              timestamp: DateTime.now(),
              hasAnimated: false,
            );
            chatNotifier.addMessageData(cardMessageData);
          }
          _scrollToBottom();
        }
        // Turn off thinking animation
        chatNotifier.setThresholdReached(false);
        chatNotifier.setIsSendingMessage(false);
      }
    } catch (e) {
      print('API call failed, not creating a fallback message: $e');
      // Turn off thinking animation
      chatNotifier.setThresholdReached(false);
      chatNotifier.setIsSendingMessage(false);
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
      case 'animatedObjectCard':
        return ChatMessageType.animatedObjectCard;
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageText: testText,
      audioUrl: apiService.getAudioUrl(testText),
      shouldAnimate: true, // Test messages should animate
      onAnimationComplete: () {
        print('Test audio message animation completed');
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
