import 'dart:async';
import 'dart:math' as math;
import 'package:fantastic_app_riverpod/providers/animation_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/message_provider.dart';
import 'package:fantastic_app_riverpod/providers/speech_recognition_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_app_bar.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_background.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_content.dart';
import 'package:fantastic_app_riverpod/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for current streaming message content
final streamingMessageProvider = StateProvider<String>((ref) => '');
final streamingMessageIdProvider = StateProvider<String?>((ref) => null);
final isStreamingProvider = StateProvider<bool>((ref) => false);

// Streaming message widget that updates in real-time
class StreamingMessageWidget extends ConsumerWidget {
  final String messageId;

  const StreamingMessageWidget({
    super.key,
    required this.messageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamingText = ref.watch(streamingMessageProvider);
    final currentStreamingId = ref.watch(streamingMessageIdProvider);
    final isStreaming = ref.watch(isStreamingProvider);

    // Only show content if this is the active streaming message
    final isActiveStream = currentStreamingId == messageId;
    final displayText = isActiveStream ? streamingText : '';

    return Container(
      key: ValueKey(messageId),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: displayText.isEmpty
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Thinking...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              if (isActiveStream && isStreaming) ...[
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'typing...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final String email;

  const ChatScreen({super.key, required this.email});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    // Get controllers locally instead of from providers to avoid ref usage after dispose
    _scrollController = ref.read(scrollControllerProvider);
    _textController = ref.read(textEditingControllerProvider);
    _focusNode = ref.read(focusNodeProvider);

    // Initialize providers that need the ticker
    ref.read(animationProvider(this));
    ref.read(messageProvider(this));

    // Add scroll controller listener
    _scrollController.addListener(_scrollListener);

    // Add text controller listener
    _textController.addListener(_handleTextInputChange);

    // Add authentication when chat screen opens
    _authenticateUser();
  }

  void _handleTextInputChange() {
    if (!mounted) return;

    final text = _textController.text;
    ref.read(chatProvider.notifier).handleTextInputChange(text);

    if (text.isNotEmpty) {
      ref.read(animationProvider(this).notifier).stopMindAnimation();
    } else if (text.isEmpty && ref.read(chatProvider).isMessageBoxVisible) {
      ref.read(animationProvider(this).notifier).startMindAnimation();
    }
  }

  void _scrollListener() {
    if (!mounted) return;

    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      final nearBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500;

      ref.read(chatProvider.notifier).updateScrollBehavior(
        userIsScrolling: true,
        nearBottom: nearBottom,
      );
    }
  }

  Future<void> _authenticateUser() async {
    final apiService = ref.read(chatApiServiceProvider);

    const defaultEmail = "string";
    const defaultPassword = "string";

    try {
      final token = await apiService.authenticate(defaultEmail, defaultPassword);

      if (token != null) {
        ref.read(authStatusProvider.notifier).state = true;

        // Load existing messages and convert them to UI widgets
        final apiMessages = await apiService.fetchMessages();
        print('Loaded ${apiMessages.length} existing messages');
        ref.read(apiMessagesProvider.notifier).state = apiMessages;

        // Convert API messages to UI widgets and add to chat state
        _loadExistingMessagesToUI(apiMessages);

        ref.read(authErrorProvider.notifier).state = null;
      } else {
        print('Authentication failed');
        ref.read(authStatusProvider.notifier).state = false;
        ref.read(authErrorProvider.notifier).state = 'Authentication failed';
      }
    } catch (e) {
      print('Authentication error: $e');
      ref.read(authStatusProvider.notifier).state = false;
      ref.read(authErrorProvider.notifier).state = 'Authentication error: $e';
    }
  }

  void _loadExistingMessagesToUI(List<ChatMessage> apiMessages) {
    for (final apiMessage in apiMessages) {
      final messageWidget = _createMessageWidget(apiMessage);
      ref.read(chatProvider.notifier).addMessage(messageWidget);
    }

    // Update threshold if needed
    if (apiMessages.length >= 5) {
      ref.read(chatProvider.notifier).setThresholdReached(true);
    }
  }

  Widget _createMessageWidget(ChatMessage apiMessage) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: apiMessage.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: apiMessage.isUser ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            apiMessage.message,
            style: TextStyle(
              color: apiMessage.isUser ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _textController.removeListener(_handleTextInputChange);
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    ref.read(chatProvider.notifier).onLongPressStart();
    ref.read(animationProvider(this).notifier).stopMindAnimation();
    ref.read(animationProvider(this).notifier).resetRipple();
    ref.read(speechRecognitionProvider.notifier).startListening();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!mounted) return;

    ref.read(speechRecognitionProvider.notifier).stopListening();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final voiceText =
          ref.read(speechRecognitionProvider).recognizedText.value;
      if (voiceText.isNotEmpty) {
        _sendCard(voiceText);
      }

      ref.read(chatProvider.notifier).onLongPressEnd();
      ref.read(animationProvider(this).notifier).startMindAnimation();
      ref.read(speechRecognitionProvider.notifier).clearText();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // Enhanced scroll to bottom that accounts for keyboard height
  void _scrollToBottomWithKeyboard() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && _scrollController.hasClients) {
          // Get the current keyboard height
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final extraPadding = keyboardHeight > 0 ? 100.0 : 50.0;

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + extraPadding,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void _sendCard(String voiceText) async {
    if (!mounted) return;

    // Check authentication
    final isAuthenticated = ref.read(authStatusProvider);
    if (!isAuthenticated) {
      print('User not authenticated');
      await _authenticateUser();

      final stillNotAuthenticated = !ref.read(authStatusProvider);
      if (stillNotAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required. Please try again.')),
        );
        return;
      }
    }

    final trimmedVoiceText = voiceText.trim();
    final messageText = _textController.text.isNotEmpty
        ? _textController.text.trim()
        : trimmedVoiceText;

    if (messageText.isEmpty) return;

    _textController.clear();

    // Set loading state
    ref.read(chatLoadingProvider.notifier).state = true;
    ref.read(chatProvider.notifier).setIsSendingMessage(true);

    try {
      // Create and add user message widget immediately
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: messageText,
        isUser: true,
        createdAt: DateTime.now(),
        messageType: 'text',
      );

      final userMessageWidget = _createMessageWidget(userMessage);
      ref.read(chatProvider.notifier).addMessage(userMessageWidget);

      _scrollToBottomWithKeyboard();

      // Send message to API with real-time streaming
      final apiService = ref.read(chatApiServiceProvider);

      // Create streaming AI message widget
      final aiMessageKey = DateTime.now().millisecondsSinceEpoch.toString();
      final streamingWidget = StreamingMessageWidget(messageId: aiMessageKey);

      // Initialize streaming state
      ref.read(streamingMessageIdProvider.notifier).state = aiMessageKey;
      ref.read(streamingMessageProvider.notifier).state = '';
      ref.read(isStreamingProvider.notifier).state = true;

      ref.read(chatProvider.notifier).addMessage(streamingWidget);
      _scrollToBottomWithKeyboard();

      // Accumulate the response text
      String aiResponseText = '';

      // Use streaming API call with real-time updates
      final response = await apiService.sendMessageWithStreaming(
        messageText,
            (String chunk) {
          if (!mounted) return;

          // Accumulate the chunk
          aiResponseText += chunk;

          // Update the streaming provider - this will trigger UI rebuild
          ref.read(streamingMessageProvider.notifier).state = aiResponseText;

          // Auto-scroll to show new content
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) _scrollToBottomWithKeyboard();
          });

          print('Received chunk: "$chunk"');
          print('Current accumulated text: "$aiResponseText"');
        },
            () {
          if (!mounted) return;

          print('Streaming complete. Final message: "$aiResponseText"');

          // Mark streaming as complete
          ref.read(isStreamingProvider.notifier).state = false;

          // Replace streaming widget with final message widget
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;

            final finalAiMessage = ChatMessage(
              id: aiMessageKey,
              message: aiResponseText,
              isUser: false,
              createdAt: DateTime.now(),
              messageType: 'text',
            );

            final finalMessageWidget = _createMessageWidget(finalAiMessage);

            // Replace the streaming widget with final message
            final currentMessages = ref.read(chatProvider).messages;
            if (currentMessages.isNotEmpty) {
              final updatedMessages = [...currentMessages];
              updatedMessages[updatedMessages.length - 1] = finalMessageWidget;

              ref.read(chatProvider.notifier).state = ref.read(chatProvider).copyWith(
                messages: updatedMessages,
              );
            }

            // Clear streaming state
            ref.read(streamingMessageIdProvider.notifier).state = null;
            ref.read(streamingMessageProvider.notifier).state = '';

            _scrollToBottom();
          });

          // Update loading states
          ref.read(chatProvider.notifier).setIsSendingMessage(false);
          ref.read(chatLoadingProvider.notifier).state = false;
        },
      );

      if (response != null) {
        print('Message sent successfully with metadata: $response');

        // Update message count threshold if needed
        final currentMessageCount = ref.read(chatProvider).messages.length;
        if (currentMessageCount >= 10) {
          ref.read(chatProvider.notifier).setThresholdReached(true);
        }
      } else {
        // Handle API error - remove the streaming message
        final currentMessages = ref.read(chatProvider).messages;
        if (currentMessages.isNotEmpty) {
          final updatedMessages = [...currentMessages];
          updatedMessages.removeLast(); // Remove the streaming widget

          ref.read(chatProvider.notifier).state = ref.read(chatProvider).copyWith(
            messages: updatedMessages,
          );
        }

        // Clear streaming state
        ref.read(streamingMessageIdProvider.notifier).state = null;
        ref.read(streamingMessageProvider.notifier).state = '';
        ref.read(isStreamingProvider.notifier).state = false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message. Please try again.')),
        );
      }

    } catch (e) {
      print('Error sending message: $e');

      // Remove streaming message on error
      final currentMessages = ref.read(chatProvider).messages;
      if (currentMessages.isNotEmpty) {
        final updatedMessages = [...currentMessages];
        updatedMessages.removeLast(); // Remove the streaming widget

        ref.read(chatProvider.notifier).state = ref.read(chatProvider).copyWith(
          messages: updatedMessages,
        );
      }

      // Clear streaming state
      ref.read(streamingMessageIdProvider.notifier).state = null;
      ref.read(streamingMessageProvider.notifier).state = '';
      ref.read(isStreamingProvider.notifier).state = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message. Please try again.')),
      );
    } finally {
      // Reset loading states
      ref.read(chatLoadingProvider.notifier).state = false;
      ref.read(chatProvider.notifier).setIsSendingMessage(false);
    }
  }

  void _toggleMessageBoxVisibility() {
    if (!mounted) return;

    ref.read(chatProvider.notifier).toggleMessageBoxVisibility();

    final isVisible = ref.read(chatProvider).isMessageBoxVisible;

    if (isVisible) {
      Future.delayed(const Duration(milliseconds: 10), () {
        if (!mounted) return;
        FocusScope.of(context).requestFocus(_focusNode);
      });

      if (_textController.text.isNotEmpty) {
        ref.read(animationProvider(this).notifier).stopMindAnimation();
      }
    } else {
      _focusNode.unfocus();
      ref.read(animationProvider(this).notifier).startMindAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final animationManager = ref.watch(animationProvider(this));
    final voiceText = ref.watch(speechRecognitionProvider).recognizedText.value;

    // Watch API states for UI feedback
    final isAuthenticated = ref.watch(authStatusProvider);
    final isLoading = ref.watch(chatLoadingProvider);
    final authError = ref.watch(authErrorProvider);

    // Get screen dimensions and keyboard height
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final viewInsets = mediaQuery.viewInsets;
    final keyboardHeight = viewInsets.bottom;

    return Scaffold(
      // Prevent the body from resizing when keyboard appears
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // Don't apply SafeArea to bottom to handle keyboard properly
        bottom: false,
        child: Stack(
          children: [
            // Background component
            ChatBackground(isThresholdReached: chatState.isThresholdReached),

            Column(
              children: [
                // App Bar component
                ChatAppBar(isThresholdReached: chatState.isThresholdReached),

                Expanded(
                  child: Container(
                    // Add bottom padding to prevent content from being hidden
                    padding: EdgeInsets.only(
                      bottom: math.max(
                        keyboardHeight,
                        mediaQuery.padding.bottom + 16, // System navigation bar + extra padding
                      ),
                    ),
                    child: ChatContent(
                      messages: chatState.messages,
                      scrollController: _scrollController,
                      textController: _textController,
                      focusNode: _focusNode,
                      isMessageBoxVisible: chatState.isMessageBoxVisible,
                      isSendingMessage: chatState.isSendingMessage || isLoading,
                      isLongPressing: chatState.isLongPressing,
                      rippleController: animationManager!.rippleController,
                      opacity: chatState.opacity,
                      displayText: chatState.displayText,
                      voiceText: voiceText,
                      shouldShowTextBox: chatState.shouldShowTextBox,
                      showMindText: chatState.showMindText,
                      showContainer: chatState.showContainer,
                      mindController: animationManager.mindController,
                      toggleMessageBoxVisibility: _toggleMessageBoxVisibility,
                      onLongPressStart: _onLongPressStart,
                      onLongPressEnd: _onLongPressEnd,
                      sendMessage: _sendCard,
                    ),
                  ),
                ),
              ],
            ),

            // Show authentication status overlay if needed
            if (!isAuthenticated && authError != null)
              Positioned(
                top: 100,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authError,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                      TextButton(
                        onPressed: _authenticateUser,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}