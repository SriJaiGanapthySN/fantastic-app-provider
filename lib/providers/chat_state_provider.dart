import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Chat state class to hold all the state variables
class ChatState {
  final List<Widget> messages;
  final bool isThresholdReached;
  final bool isMessageBoxVisible;
  final double opacity;
  final bool isLongPressing;
  final String displayText;
  final bool showContainer;
  final bool isSendingMessage;
  final bool isUserSendingMessage;
  final bool shouldShowTextBox;
  final bool showMindText;
  final bool userIsScrolling;
  final bool shouldAutoScroll;
  final bool isQuestion;

  ChatState({
    required this.messages,
    this.isThresholdReached = false,
    this.isMessageBoxVisible = false,
    this.opacity = 0.0,
    this.isLongPressing = false,
    this.displayText = "Hold to Speak",
    this.showContainer = false,
    this.isSendingMessage = false,
    this.isUserSendingMessage = false,
    this.shouldShowTextBox = false,
    this.showMindText = true,
    this.userIsScrolling = false,
    this.shouldAutoScroll = true,
    this.isQuestion = false,
  });

  // Create a new state based on the current one
  ChatState copyWith({
    List<Widget>? messages,
    bool? isThresholdReached,
    bool? isMessageBoxVisible,
    double? opacity,
    bool? isLongPressing,
    String? displayText,
    bool? showContainer,
    bool? isSendingMessage,
    bool? isUserSendingMessage,
    bool? shouldShowTextBox,
    bool? showMindText,
    bool? userIsScrolling,
    bool? shouldAutoScroll,
    bool? isQuestion,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isThresholdReached: isThresholdReached ?? this.isThresholdReached,
      isMessageBoxVisible: isMessageBoxVisible ?? this.isMessageBoxVisible,
      opacity: opacity ?? this.opacity,
      isLongPressing: isLongPressing ?? this.isLongPressing,
      displayText: displayText ?? this.displayText,
      showContainer: showContainer ?? this.showContainer,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      isUserSendingMessage: isUserSendingMessage ?? this.isUserSendingMessage,
      shouldShowTextBox: shouldShowTextBox ?? this.shouldShowTextBox,
      showMindText: showMindText ?? this.showMindText,
      userIsScrolling: userIsScrolling ?? this.userIsScrolling,
      shouldAutoScroll: shouldAutoScroll ?? this.shouldAutoScroll,
      isQuestion: isQuestion ?? this.isQuestion,
    );
  }
}

// Chat notifier to manage the state
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref ref;
  Timer? _timer;
  bool _disposed = false;

  ChatNotifier(this.ref) : super(ChatState(messages: [])) {
    _initialize();
  }

  void _initialize() {
    // Show container after delay
    Future.delayed(Duration(seconds: 1), () {
      if (_disposed) return;
      state = state.copyWith(showContainer: true);
    });

    // Fade in opacity
    Future.delayed(Duration(seconds: 3), () {
      if (_disposed) return;
      state = state.copyWith(opacity: 1.0);
    });

    _startTextSwitching();
  }

  void _startTextSwitching() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      final newText = (state.displayText == "Hold to Speak")
          ? "Tap to Chat"
          : "Hold to Speak";
      state = state.copyWith(displayText: newText);
    });
  }

  void toggleMessageBoxVisibility() {
    final newVisibility = !state.isMessageBoxVisible;
    state = state.copyWith(
      isMessageBoxVisible: newVisibility,
      showMindText: newVisibility ? state.showMindText : true,
      shouldShowTextBox: newVisibility ? state.shouldShowTextBox : true,
    );

    if (!newVisibility) {
      // When hiding message box, reset mind text state
      state = state.copyWith(showMindText: true, shouldShowTextBox: true);
      // Animation manager will be called through a separate provider
    }
  }

  void onLongPressStart() {
    state = state.copyWith(
      isLongPressing: true,
      showMindText: false,
      shouldShowTextBox: false,
    );
    // Animation and speech actions will be handled via their respective providers
  }

  void onLongPressEnd() {
    state = state.copyWith(
      isLongPressing: false,
      showMindText: true,
      shouldShowTextBox: true,
    );
    // Animation and speech actions will be handled via their respective providers
  }

  void addMessage(Widget message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  void setIsSendingMessage(bool value) {
    state = state.copyWith(isSendingMessage: value);
  }

  void setIsUserSendingMessage(bool value) {
    state = state.copyWith(isUserSendingMessage: value);
  }

  void setIsQuestion(bool value) {
    state = state.copyWith(isQuestion: value);
  }

  void setThresholdReached(bool value) {
    state = state.copyWith(isThresholdReached: value);
  }

  void handleTextInputChange(String text) {
    if (text.isNotEmpty && state.showMindText) {
      state = state.copyWith(
        showMindText: false,
        shouldShowTextBox: false,
      );
      // Animation stopping will be handled via animation provider
    } else if (text.isEmpty &&
        !state.showMindText &&
        state.isMessageBoxVisible) {
      state = state.copyWith(
        showMindText: true,
        shouldShowTextBox: true,
      );
      // Animation starting will be handled via animation provider
    }
  }

  void updateScrollBehavior(
      {required bool userIsScrolling, required bool nearBottom}) {
    state = state.copyWith(
      userIsScrolling: userIsScrolling,
      shouldAutoScroll: nearBottom,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

// Provider for the chat state
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

// Provider for the text editing controller
final textEditingControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// Provider for the scroll controller
final scrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// Provider for the focus node
final focusNodeProvider = Provider<FocusNode>((ref) {
  final focusNode = FocusNode();
  ref.onDispose(() => focusNode.dispose());
  return focusNode;
});
