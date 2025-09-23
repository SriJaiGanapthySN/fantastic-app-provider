import 'dart:async';
import 'package:fantastic_app_riverpod/providers/animation_provider.dart';
import 'package:fantastic_app_riverpod/providers/auth_provider.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';
import 'package:fantastic_app_riverpod/providers/message_provider.dart';
import 'package:fantastic_app_riverpod/providers/speech_recognition_provider.dart';
import 'package:fantastic_app_riverpod/providers/nav_provider.dart';
import 'package:fantastic_app_riverpod/screens/main_screen.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_app_bar.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_background.dart';
import 'package:fantastic_app_riverpod/widgets/chat/chat_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    print('CHAT SCREEN INITIALIZED with email: ${widget.email}');

    // Defer initialization to avoid accessing ref during initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    if (!mounted || _isInitialized) return;

    try {
      // Get controllers from providers safely after build
      _scrollController = ref.read(scrollControllerProvider);
      _textController = ref.read(textEditingControllerProvider);
      _focusNode = ref.read(focusNodeProvider);

      // Remove any existing listeners
      try {
        _scrollController.removeListener(_scrollListener);
      } catch (e) {
        // Listener might not exist yet
      }

      // Initialize providers that need the ticker
      ref.read(animationProvider(this));
      ref.read(messageProvider(this));

      // Add scroll controller listener
      _scrollController.addListener(_scrollListener);

      // Text controller listener is now handled in MessageInputBar
      // No need to add it here to avoid double handling

      // Set up animation callback for scrolling
      _setupAnimationCallback();

      _isInitialized = true;

      // Trigger a rebuild to show the content
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error during chat screen initialization: $e');
      // Retry initialization after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_isInitialized) {
          _initializeControllers();
        }
      });
    }
  }

  void _setupAnimationCallback() {
    if (!mounted || !_isInitialized) return;

    try {
      final animationManager = ref.read(animationProvider(this));
      if (animationManager != null) {
        // Only set callback for mind animation, not ripple
        animationManager.onAnimationStart = () {
          // Only scroll when there are actual messages and not during voice input
          if (mounted &&
              ref.read(chatProvider).messages.isNotEmpty &&
              !ref.read(chatProvider).isLongPressing) {
            _scrollToBottom();
          }
        };
      }
    } catch (e) {
      print('Error setting up animation callback: $e');
    }
  }

  void _handleTextInputChange() {
    if (!mounted || !_isInitialized) return;

    try {
      final text = _textController.text;
      ref.read(chatProvider.notifier).handleTextInputChange(text);

      if (text.isNotEmpty) {
        ref.read(animationProvider(this).notifier).stopMindAnimation();
      } else if (text.isEmpty && ref.read(chatProvider).isMessageBoxVisible) {
        ref.read(animationProvider(this).notifier).startMindAnimation();
      }
    } catch (e) {
      print('Error handling text input change: $e');
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
    try {
      if (_isInitialized) {
        _scrollController.removeListener(_scrollListener);
        // Text controller listener is now handled in MessageInputBar
      }
    } catch (e) {
      print('Error removing listeners: $e');
    }

    // Only dispose if providers were initialized
    if (_isInitialized) {
      try {
        final animationNotifier = ref.read(animationProvider(this).notifier);
        animationNotifier.dispose();
      } catch (e) {
        print('Error disposing animation provider: $e');
        // ignore — provider might not be created or already disposed
      }

      try {
        final messageNotifier = ref.read(messageProvider(this).notifier);
        messageNotifier.dispose();
      } catch (e) {
        print('Error disposing message provider: $e');
        // ignore — provider might not be created or already disposed
      }
    }

    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (!mounted || !_isInitialized) return;

    try {
      ref.read(chatProvider.notifier).onLongPressStart();
      ref.read(animationProvider(this).notifier).stopMindAnimation();
      ref.read(animationProvider(this).notifier).resetRipple();
      ref.read(speechRecognitionProvider.notifier).startListening();
    } catch (e) {
      print('Error in long press start: $e');
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!mounted || !_isInitialized) return;

    try {
      ref.read(speechRecognitionProvider.notifier).stopListening();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || !_isInitialized) return;

        try {
          final voiceText =
              ref.read(speechRecognitionProvider).recognizedText.value;
          if (voiceText.isNotEmpty) {
            _sendVoiceMessage(
                voiceText); // Use voice message method for voice input
          }

          ref.read(chatProvider.notifier).onLongPressEnd();
          ref.read(animationProvider(this).notifier).startMindAnimation();
          ref.read(speechRecognitionProvider.notifier).clearText();
        } catch (e) {
          print('Error in long press end delayed action: $e');
        }
      });
    } catch (e) {
      print('Error in long press end: $e');
    }
  }

  void _scrollToBottom() {
    if (!mounted || !_isInitialized) return;

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
    if (!mounted || !_isInitialized) return;

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
    if (!mounted || !_isInitialized) return;

    try {
      final trimmedMessageText = messageText.trim();
      final finalMessageText = _textController.text.isNotEmpty
          ? _textController.text.trim()
          : trimmedMessageText;

      if (finalMessageText.isEmpty) return;

      _textController.clear();

      // Use the message provider to send the message with animations (text input)
      ref
          .read(messageProvider(this).notifier)
          .sendMessage(finalMessageText, inputType: 'text');

      _scrollToBottomWithKeyboard();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _sendVoiceMessage(String voiceText) async {
    if (!mounted || !_isInitialized) return;

    try {
      final trimmedVoiceText = voiceText.trim();
      if (trimmedVoiceText.isEmpty) return;

      // Use the message provider to send the voice message with animations (voice input)
      ref
          .read(messageProvider(this).notifier)
          .sendMessage(trimmedVoiceText, inputType: 'voice');

      _scrollToBottomWithKeyboard();
    } catch (e) {
      print('Error sending voice message: $e');
    }
  }

  void _toggleMessageBoxVisibility() {
    if (!mounted || !_isInitialized) return;

    try {
      print('Toggling message box visibility...');
      ref.read(chatProvider.notifier).toggleMessageBoxVisibility();

      final isVisible = ref.read(chatProvider).isMessageBoxVisible;
      print('Message box visible: $isVisible');

      if (isVisible) {
        // Give the UI time to rebuild before requesting focus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _focusNode.canRequestFocus) {
            print('Requesting focus for text field');
            _focusNode.requestFocus();
          }
        });

        if (_textController.text.isNotEmpty) {
          ref.read(animationProvider(this).notifier).stopMindAnimation();
        } else {
          ref.read(animationProvider(this).notifier).startMindAnimation();
        }
      } else {
        print('Unfocusing text field');
        _focusNode.unfocus();
        ref.read(animationProvider(this).notifier).startMindAnimation();
      }
    } catch (e) {
      print('Error toggling message box visibility: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the auth provider instead of FutureBuilder to avoid repeated auth checks
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Prevent white flash
      resizeToAvoidBottomInset: true,
      body: _buildChatBody(context, authState),
    );
  }

  Widget _buildChatBody(BuildContext context, AuthState authState) {
    // Check authentication state from provider
    if (authState.isLoading) {
      return Stack(
        children: [
          // Show background even during loading
          const ChatBackground(isThresholdReached: false),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      );
    }

    final isAuthenticated = authState.user != null;
    if (!isAuthenticated) {
      return Stack(
        children: [
          const ChatBackground(isThresholdReached: false),
          const Center(
            child: Text(
              'Authentication required. Please log in.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      );
    }

    final chatState = ref.watch(chatProvider);

    // Only watch animation provider if initialized - don't rebuild on animation changes
    final animationManager =
        _isInitialized ? ref.read(animationProvider(this)) : null;

    // Don't watch speech recognition provider constantly - read it only when needed
    // final voiceText = ref.watch(speechRecognitionProvider).recognizedText.value;

    // Show loading with background if not initialized yet
    if (!_isInitialized) {
      return Stack(
        children: [
          const ChatBackground(isThresholdReached: false),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // Background stretches to full screen
        ChatBackground(
          isThresholdReached: chatState.isThresholdReached,
        ),
        // App bar positioned at the top, overlays background
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: ChatAppBar(
            isThresholdReached: chatState.isThresholdReached,
            onMenuPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (sheetContext) {
                  final providerContainer =
                      ProviderScope.containerOf(sheetContext, listen: false);
                  final pageController =
                      providerContainer.read(pageControllerProvider);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: SvgPicture.asset('assets/icons/heart.svg',
                            color: Colors.black),
                        title: const Text('Rituals'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          providerContainer
                              .read(selectedTabProvider.notifier)
                              .state = 1;
                          pageController.jumpToPage(1);
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset('assets/icons/route.svg',
                            color: Colors.black),
                        title: const Text('Journey'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          providerContainer
                              .read(selectedTabProvider.notifier)
                              .state = 2;
                          pageController.jumpToPage(2);
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset('assets/icons/search.svg',
                            color: Colors.black),
                        title: const Text('Discover'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          providerContainer
                              .read(selectedTabProvider.notifier)
                              .state = 3;
                          pageController.jumpToPage(3);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Main chat content, offset below app bar
        if (animationManager != null)
          Positioned.fill(
            top: kToolbarHeight +
                MediaQuery.of(context)
                    .padding
                    .top, // Offset by app bar height + safe area
            child: ChatContent(
              messageData: chatState.messageData,
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
              voiceText:
                  ref.read(speechRecognitionProvider).recognizedText.value,
              shouldShowTextBox: chatState.shouldShowTextBox,
              showMindText: chatState.showMindText,
              showContainer: chatState.showContainer,
              mindController: animationManager.mindController,
              tickerProvider: this,
              toggleMessageBoxVisibility: _toggleMessageBoxVisibility,
              onLongPressStart: _onLongPressStart,
              onLongPressEnd: _onLongPressEnd,
              sendMessage: _sendMessage,
            ),
          ),
      ],
    );
  }
}
