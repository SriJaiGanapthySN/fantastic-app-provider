import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/utils/question_detector.dart';
import 'package:fantastic_app_riverpod/providers/auth_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';
import 'package:fantastic_app_riverpod/models/responsemodel.dart';
import 'package:fantastic_app_riverpod/services/bracketed_content_service.dart';

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

    // Check for test content card command
    if (messageText.toLowerCase().contains('test content card')) {
      addTestContentCard();
      return;
    }

    // Check for specific content type tests
    if (messageText.toLowerCase().contains('test habit card')) {
      addTestContentCardOfType('HABIT');
      return;
    }

    if (messageText.toLowerCase().contains('test journey card')) {
      addTestContentCardOfType('JOURNEY');
      return;
    }

    if (messageText.toLowerCase().contains('test coaching card')) {
      addTestContentCardOfType('COACHING');
      return;
    }

    if (messageText.toLowerCase().contains('test challenge card')) {
      addTestContentCardOfType('CHALLENGE');
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
      // Check authentication using the auth provider instead of repeated TokenService calls
      final authState = ref.read(authProvider);
      if (authState.user == null) {
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
          print('Received chunk: "$chunk" (length: ${chunk.length})');
          fullResponse += chunk;
          print('Full response so far: ${fullResponse.length} characters');
        },
        () async {
          // Streaming complete - check if provider is still valid
          try {
            print(
                'Streaming complete, handling original inputType: $inputType');
            print('Full response received: ${fullResponse.length} characters');

            if (fullResponse.isNotEmpty) {
              final messageId =
                  DateTime.now().millisecondsSinceEpoch.toString();
              print('Creating message with ID: $messageId');

              // Create different message types based on input type
              if (inputType == 'voice') {
                final audioMessageData = ChatMessageData(
                  id: messageId + '_audio',
                  text: "",
                  type: ChatMessageType.audioMessage,
                  isUser: false,
                  audioUrl: apiService.getAudioUrl(fullResponse),
                  timestamp: DateTime.now(),
                  hasAnimated: false,
                );
                print(
                    'Adding audio message data with ID: ${audioMessageData.id}');
                chatNotifier.addMessageData(audioMessageData);
                print(
                    'Audio message data added successfully. Total messages: ${ref.read(chatProvider).messageData.length}');
              } else {
                final cardMessageData = ChatMessageData(
                  id: messageId + '_card',
                  text: fullResponse,
                  type: ChatMessageType.cardMessage,
                  isUser: false,
                  isQuestion: isQuestion,
                  timestamp: DateTime.now(),
                  hasAnimated: false,
                );
                print(
                    'Adding card message data with ID: ${cardMessageData.id}');
                print(
                    'Card message text: ${cardMessageData.text.substring(0, cardMessageData.text.length > 50 ? 50 : cardMessageData.text.length)}...');
                chatNotifier.addMessageData(cardMessageData);
                print(
                    'Card message data added successfully. Total messages: ${ref.read(chatProvider).messageData.length}');
              }
              _scrollToBottom();
            } else {
              print('WARNING: Empty fullResponse received from streaming');
            }
            // Turn off thinking animation
            chatNotifier.setThresholdReached(false);
            chatNotifier.setIsSendingMessage(false);
          } catch (e) {
            print('Error in streaming completion callback: $e');
            // Ensure we always turn off loading states even on error
            try {
              chatNotifier.setThresholdReached(false);
              chatNotifier.setIsSendingMessage(false);
            } catch (e2) {
              print('Error turning off loading states: $e2');
            }
          }
        },
        inputType: apiInputType,
      );

      // Store bracketed content if available in the response metadata
      if (response != null && response['has_bracketed_content'] == true) {
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();
        final responseModel = response['response_model'] as ChatResponseModel?;

        final finalMessageId =
            inputType == 'voice' ? messageId + '_audio' : messageId + '_card';

        if (responseModel != null) {
          BracketedContentService.storeResponseModel(
              finalMessageId, responseModel);

          // Check if this response should trigger a content card
          if (_shouldCreateContentCard(responseModel)) {
            _createContentCardMessage(
                responseModel, finalMessageId + '_content_card', chatNotifier);
          }
        }
      }

      // If streaming failed, fall back to regular response
      if (response == null && fullResponse.isEmpty) {
        print(
            'Streaming failed, falling back to regular API call with inputType: $apiInputType');
        final regularResponse = await apiService.sendMessage(userMessageText,
            inputType: apiInputType);

        // Debug the fallback response
        print('🔍 Fallback API Response Debug:');
        print('  - regularResponse is null: ${regularResponse == null}');
        if (regularResponse != null) {
          print('  - regularResponse keys: ${regularResponse.keys.toList()}');
          print(
              '  - ai_message_content exists: ${regularResponse.containsKey('ai_message_content')}');
          if (regularResponse.containsKey('ai_message_content')) {
            final content = regularResponse['ai_message_content'];
            print('  - ai_message_content value: "$content"');
            print('  - ai_message_content length: ${content?.length ?? 0}');
            print(
                '  - ai_message_content is empty: ${content?.isEmpty ?? true}');
          }
        }

        if (regularResponse != null &&
            regularResponse['ai_message_content'] != null) {
          final apiResponse = regularResponse['ai_message_content'];
          final messageId = DateTime.now().millisecondsSinceEpoch.toString();

          print(
              '📝 Creating fallback message with apiResponse: "$apiResponse"');

          if (inputType == 'voice') {
            if (apiResponse.isNotEmpty) {
              final audioMessageData = ChatMessageData(
                id: messageId + '_audio_fallback',
                text: "",
                type: ChatMessageType.audioMessage,
                isUser: false,
                audioUrl: apiService.getAudioUrl(apiResponse),
                timestamp: DateTime.now(),
                hasAnimated: false,
              );
              chatNotifier.addMessageData(audioMessageData);

              // Store bracketed content for fallback response
              if (regularResponse['has_bracketed_content'] == true) {
                final responseModel =
                    regularResponse['response_model'] as ChatResponseModel?;
                if (responseModel != null) {
                  BracketedContentService.storeResponseModel(
                      messageId + '_audio_fallback', responseModel);

                  // Check if this response should trigger a content card
                  if (_shouldCreateContentCard(responseModel)) {
                    _createContentCardMessage(
                        responseModel,
                        messageId + '_audio_fallback_content_card',
                        chatNotifier);
                  }
                }
              }
            }
          } else {
            final cardMessageData = ChatMessageData(
              id: messageId + '_card_fallback',
              text: apiResponse,
              type: ChatMessageType.cardMessage,
              isUser: false,
              isQuestion: isQuestion,
              timestamp: DateTime.now(),
              hasAnimated: false,
            );
            chatNotifier.addMessageData(cardMessageData);

            // Store bracketed content for fallback response
            if (regularResponse['has_bracketed_content'] == true) {
              final responseModel =
                  regularResponse['response_model'] as ChatResponseModel?;
              if (responseModel != null) {
                BracketedContentService.storeResponseModel(
                    messageId + '_card_fallback', responseModel);

                // Check if this response should trigger a content card
                if (_shouldCreateContentCard(responseModel)) {
                  _createContentCardMessage(responseModel,
                      messageId + '_card_fallback_content_card', chatNotifier);
                }
              }
            }
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

  // Test method to add a content card message for demonstration
  void addTestContentCard() {
    final chatNotifier = ref.read(chatProvider.notifier);

    // Add user message first
    final userMessageData = ChatMessageData(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_user_test',
      text: 'test content card',
      type: ChatMessageType.userMessage,
      isUser: true,
      timestamp: DateTime.now(),
      hasAnimated: false,
    );
    chatNotifier.addMessageData(userMessageData);

    // Add content card message with descriptive text
    final contentCardData = ChatMessageData(
      id: DateTime.now().millisecondsSinceEpoch.toString() +
          '_content_card_test',
      text: _buildContentCardText('HABIT', 'test-habit-id-123'),
      type: ChatMessageType.contentCard,
      isUser: false,
      timestamp: DateTime.now(),
      hasAnimated: false,
      objectId: 'test-habit-id-123',
      contentType: 'HABIT',
    );

    chatNotifier.addMessageData(contentCardData);
    print(
        '🎴 Created test content card message for HABIT with ID: test-habit-id-123');
    _scrollToBottom();
  }

  // Test method to add content cards of specific types
  void addTestContentCardOfType(String type) {
    final chatNotifier = ref.read(chatProvider.notifier);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Add user message first
    final userMessageData = ChatMessageData(
      id: timestamp + '_user_test',
      text: 'test ${type.toLowerCase()} card',
      type: ChatMessageType.userMessage,
      isUser: true,
      timestamp: DateTime.now(),
      hasAnimated: false,
    );
    chatNotifier.addMessageData(userMessageData);

    // Add content card message with type-specific content
    final objectId =
        'test-${type.toLowerCase()}-id-${timestamp.substring(timestamp.length - 6)}';
    final contentCardData = ChatMessageData(
      id: timestamp + '_content_card_test',
      text: _buildContentCardText(type, objectId),
      type: ChatMessageType.contentCard,
      isUser: false,
      timestamp: DateTime.now(),
      hasAnimated: false,
      objectId: objectId,
      contentType: type,
    );

    chatNotifier.addMessageData(contentCardData);
    print('🎴 Created test content card message for $type with ID: $objectId');
    _scrollToBottom();
  }

  // Helper method to check if a content card should be created
  bool _shouldCreateContentCard(ChatResponseModel responseModel) {
    return responseModel.hasObjectId &&
        responseModel.hasType &&
        _isValidContentType(responseModel.type!);
  }

  // Helper method to validate content types
  bool _isValidContentType(String type) {
    const validTypes = ['HABIT', 'JOURNEY', 'COACHING', 'CHALLENGE'];
    return validTypes.contains(type.toUpperCase());
  }

  // Helper method to create content card message
  void _createContentCardMessage(ChatResponseModel responseModel,
      String messageId, ChatNotifier chatNotifier) {
    // Create a descriptive message for the content card
    String cardText =
        _buildContentCardText(responseModel.type!, responseModel.objectId!);

    final contentCardData = ChatMessageData(
      id: messageId,
      text: cardText,
      type: ChatMessageType.contentCard,
      isUser: false,
      timestamp: DateTime.now(),
      hasAnimated: false,
      objectId: responseModel.objectId,
      contentType: responseModel.type,
    );

    chatNotifier.addMessageData(contentCardData);
    print(
        '🎴 Created content card message for ${responseModel.type} with ID: ${responseModel.objectId}');
  }

  // Helper method to build content card text
  String _buildContentCardText(String type, String objectId) {
    switch (type.toUpperCase()) {
      case 'HABIT':
        return '🎯 Here\'s your habit!\n\nI found the habit you were looking for. This habit will help you build positive routines and achieve your goals.\n\nHabit ID: $objectId';
      case 'JOURNEY':
        return '🗺️ Here\'s your journey!\n\nI located the journey for you. This learning path will guide you through structured skill development.\n\nJourney ID: $objectId';
      case 'COACHING':
        return '🧭 Here\'s your coaching session!\n\nI found the coaching content you requested. This will provide personalized guidance and support.\n\nCoaching ID: $objectId';
      case 'CHALLENGE':
        return '🏆 Here\'s your challenge!\n\nI discovered the challenge you\'re looking for. Ready to test your skills and push your limits?\n\nChallenge ID: $objectId';
      default:
        return '📋 Here\'s the ${type.toLowerCase()} you requested!\n\nContent ID: $objectId';
    }
  }
}

final messageProvider = StateNotifierProvider.family<MessageNotifier,
    MessageFactory?, TickerProvider>((ref, tickerProvider) {
  return MessageNotifier(ref, tickerProvider);
});
