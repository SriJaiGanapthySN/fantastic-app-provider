import 'dart:async';
import 'package:fantastic_app_riverpod/providers/animation_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/message_provider.dart';
import 'package:fantastic_app_riverpod/providers/speech_recognition_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_api_provider.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_app_bar.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_background.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    // Set up animation callback for scrolling
    _setupAnimationCallback();

    // Initialize authentication
    _initializeAuthentication();
  }

  Future<void> _initializeAuthentication() async {
    final apiService = ref.read(chatApiServiceProvider);
    const defaultEmail = "string";
    const defaultPassword = "string";

    try {
      final token =
          await apiService.authenticate(defaultEmail, defaultPassword);
      if (token != null) {
        ref.read(authStatusProvider.notifier).state = true;
        print('✅ Authentication successful in ChatScreen');
      } else {
        print('❌ Authentication failed in ChatScreen');
      }
    } catch (e) {
      print('💥 Authentication error in ChatScreen: $e');
    }
  }

  void _setupAnimationCallback() {
    final animationManager = ref.read(animationProvider(this));
    if (animationManager != null) {
      // Only set callback for mind animation, not ripple
      animationManager.onAnimationStart = () {
        // Only scroll when there are actual messages and not during voice input
        if (ref.read(chatProvider).messages.isNotEmpty &&
            !ref.read(chatProvider).isLongPressing) {
          _scrollToBottom();
        }
      };
    }
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
        _sendMessage(voiceText);
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
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage(String messageText) async {
    if (!mounted) return;

    final trimmedMessageText = messageText.trim();
    final finalMessageText = _textController.text.isNotEmpty
        ? _textController.text.trim()
        : trimmedMessageText;

    if (finalMessageText.isEmpty) return;

    _textController.clear();

    // Use the message provider to send the message with animations
    ref.read(messageProvider(this).notifier).sendMessage(finalMessageText);

    _scrollToBottomWithKeyboard();
  }

  void _toggleMessageBoxVisibility() {
    if (!mounted) return;

    ref.read(chatProvider.notifier).toggleMessageBoxVisibility();

    final isVisible = ref.read(chatProvider).isMessageBoxVisible;

    if (isVisible) {
      Future.delayed(const Duration(milliseconds: 10), () {
        FocusScope.of(context).requestFocus(_focusNode);
      });

      if (_textController.text.isNotEmpty) {
        ref.read(animationProvider(this).notifier).stopMindAnimation();
      } else {
        ref.read(animationProvider(this).notifier).startMindAnimation();
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

    return Scaffold(
      // Prevent the body from resizing when keyboard appears
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            ChatBackground(
              isThresholdReached: chatState.isThresholdReached,
            ),
            // App bar
            ChatAppBar(
              isThresholdReached: chatState.isThresholdReached,
            ),
            // Main chat content
            if (animationManager != null)
              Positioned.fill(
                top: 60, // Account for app bar
                child: ChatContent(
                  messages: chatState.messages,
                  scrollController: _scrollController,
                  textController: _textController,
                  focusNode: _focusNode,
                  isMessageBoxVisible: chatState.isMessageBoxVisible,
                  isSendingMessage: chatState.isSendingMessage,
                  isLongPressing: chatState.isLongPressing,
                  rippleController: animationManager.rippleController,
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
                  sendMessage: _sendMessage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
