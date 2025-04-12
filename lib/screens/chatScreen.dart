// ignore_for_file: file_names
import 'dart:async';
import 'package:fantastic_app_riverpod/providers/animation_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/message_provider.dart';
import 'package:fantastic_app_riverpod/providers/speech_recognition_provider.dart';
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
    // Store the disposal callbacks for proper cleanup
    ref.read(animationProvider(this));
    ref.read(messageProvider(this));

    // Add scroll controller listener
    _scrollController.addListener(_scrollListener);

    // Add text controller listener
    _textController.addListener(_handleTextInputChange);
  }

  void _handleTextInputChange() {
    if (!mounted) return; // Prevent using ref after dispose

    final text = _textController.text;
    ref.read(chatProvider.notifier).handleTextInputChange(text);

    if (text.isNotEmpty) {
      ref.read(animationProvider(this).notifier).stopMindAnimation();
    } else if (text.isEmpty && ref.read(chatProvider).isMessageBoxVisible) {
      ref.read(animationProvider(this).notifier).startMindAnimation();
    }
  }

  // Scroll listener to detect user scrolling
  void _scrollListener() {
    if (!mounted) return; // Prevent using ref after dispose

    // If user is scrolling manually
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      // Check if user is near bottom
      final nearBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;

      ref.read(chatProvider.notifier).updateScrollBehavior(
            userIsScrolling: true,
            nearBottom: nearBottom,
          );
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _scrollController.removeListener(_scrollListener);
    _textController.removeListener(_handleTextInputChange);

    // Note: We don't dispose these controllers here because they're managed by their providers
    // The providers themselves handle the disposal

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

    final voiceText =
        ref.read(speechRecognitionProvider.notifier).recognizedText;
    if (voiceText.isNotEmpty) {
      _sendCard(voiceText);
    }

    ref.read(chatProvider.notifier).onLongPressEnd();
    ref.read(animationProvider(this).notifier).startMindAnimation();
    ref.read(speechRecognitionProvider.notifier).stopListening();
    ref.read(speechRecognitionProvider.notifier).clearText();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Increased delay to allow UI to fully update with the new message
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(
                milliseconds: 500), // Longer duration for smoother animation
            curve: Curves.easeOutCubic, // More natural feeling curve
          );
        }
      });
    }
  }

  void _sendCard(String voiceText) {
    if (!mounted) return;

    final messageText = _textController.text.isNotEmpty
        ? _textController.text.trim()
        : voiceText;
    _textController.clear();

    ref.read(messageProvider(this).notifier).sendMessage(messageText);

    // Ensure we scroll down when sending a message
    _scrollToBottom();

    // Also scroll when the response starts (AI response)
    // Add a slightly longer delay for AI response animation to begin
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _scrollToBottom();
      }
    });
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

    return Scaffold(
      body: Stack(
        children: [
          // Background component
          ChatBackground(isThresholdReached: chatState.isThresholdReached),

          Column(
            children: [
              // App Bar component
              ChatAppBar(isThresholdReached: chatState.isThresholdReached),

              Expanded(
                child: ChatContent(
                  messages: chatState.messages,
                  scrollController: _scrollController,
                  textController: _textController,
                  focusNode: _focusNode,
                  isMessageBoxVisible: chatState.isMessageBoxVisible,
                  isSendingMessage: chatState.isSendingMessage,
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
            ],
          ),
        ],
      ),
    );
  }
}
