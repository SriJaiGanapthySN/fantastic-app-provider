import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';

// Chat state class to hold all the state variables
class ChatState {
  final List<ChatMessageData> messageData; // Changed from Widget to data
  final List<Widget> messages; // Keep widgets for backward compatibility
  final bool isThresholdReached;
  final bool isMessageBoxVisible;
  final double opacity;
  final bool isLongPressing;
  final String displayText;
  final String currentText; // Add this to track text input
  final bool showContainer;
  final bool isSendingMessage;
  final bool isUserSendingMessage;
  final bool shouldShowTextBox;
  final bool showMindText;
  final bool userIsScrolling;
  final bool shouldAutoScroll;
  final bool isQuestion;

  ChatState({
    required this.messageData,
    required this.messages,
    this.isThresholdReached = false,
    this.isMessageBoxVisible = false,
    this.opacity = 0.0,
    this.isLongPressing = false,
    this.displayText = "Hold to Speak",
    this.currentText = "", // Add default value
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
    List<ChatMessageData>? messageData,
    List<Widget>? messages,
    bool? isThresholdReached,
    bool? isMessageBoxVisible,
    double? opacity,
    bool? isLongPressing,
    String? displayText,
    String? currentText,
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
      messageData: messageData ?? this.messageData,
      messages: messages ?? this.messages,
      isThresholdReached: isThresholdReached ?? this.isThresholdReached,
      isMessageBoxVisible: isMessageBoxVisible ?? this.isMessageBoxVisible,
      opacity: opacity ?? this.opacity,
      isLongPressing: isLongPressing ?? this.isLongPressing,
      displayText: displayText ?? this.displayText,
      currentText: currentText ?? this.currentText,
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

  ChatNotifier(this.ref) : super(ChatState(messageData: [], messages: [])) {
    _initialize();
  }

  void _initialize() {
    // Show container after delay
    Future.delayed(Duration(seconds: 1), () {
      if (_disposed) return;
      try {
        state = state.copyWith(showContainer: true);
      } catch (e) {
        print('Error updating showContainer: $e');
      }
    });

    // Fade in opacity
    Future.delayed(Duration(seconds: 3), () {
      if (_disposed) return;
      try {
        state = state.copyWith(opacity: 1.0);
      } catch (e) {
        print('Error updating opacity: $e');
      }
    });

    _startTextSwitching();
  }

  void _startTextSwitching() {
    // Only start text switching if not already running
    if (_timer != null && _timer!.isActive) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      try {
        final newText = (state.displayText == "Hold to Speak")
            ? "Tap to Chat"
            : "Hold to Speak";

        // Add additional check to prevent updating disposed state
        if (!_disposed) {
          state = state.copyWith(displayText: newText);
        }
      } catch (e) {
        // If state update fails, cancel the timer to prevent further errors
        print('Error updating display text: $e');
        timer.cancel();
        _timer = null;
      }
    });
  }

  void stopTextSwitching() {
    _timer?.cancel();
    _timer = null;
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

  // New method to add message data
  void addMessageData(ChatMessageData messageData) {
    if (!_disposed) {
      try {
        final updatedMessageData = [...state.messageData, messageData];
        state = state.copyWith(messageData: updatedMessageData);
      } catch (e) {
        print('Error adding message data: $e');
      }
    }
  }

  // Method to mark a message as animated
  void markMessageAsAnimated(String messageId) {
    if (!_disposed) {
      try {
        final updatedMessageData = state.messageData.map((msg) {
          if (msg.id == messageId) {
            return msg.copyWith(hasAnimated: true);
          }
          return msg;
        }).toList();
        state = state.copyWith(messageData: updatedMessageData);
      } catch (e) {
        print('Error marking message as animated: $e');
      }
    }
  }

  void removeLastMessage() {
    if (state.messages.isNotEmpty) {
      final updatedMessages =
          state.messages.sublist(0, state.messages.length - 1);
      state = state.copyWith(messages: updatedMessages);
    }
  }

  // New method to remove last message data
  void removeLastMessageData() {
    if (state.messageData.isNotEmpty) {
      final updatedMessageData =
          state.messageData.sublist(0, state.messageData.length - 1);
      state = state.copyWith(messageData: updatedMessageData);
    }
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
    if (!_disposed) {
      try {
        state = state.copyWith(isThresholdReached: value);
      } catch (e) {
        print('Error setting threshold reached: $e');
      }
    }
  }

  void handleTextInputChange(String text) {
    // Only update state if there's a meaningful change
    final wasEmpty = state.currentText.isEmpty;
    final isEmpty = text.isEmpty;

    // Update current text
    state = state.copyWith(currentText: text);

    // Only update UI state when transitioning between empty and non-empty
    if (wasEmpty != isEmpty) {
      if (text.isNotEmpty && state.showMindText) {
        state = state.copyWith(
          showMindText: false,
          shouldShowTextBox: false,
        );
        print('Text input: hiding mind animation');
      } else if (text.isEmpty &&
          !state.showMindText &&
          state.isMessageBoxVisible) {
        state = state.copyWith(
          showMindText: true,
          shouldShowTextBox: true,
        );
        print('Text input: showing mind animation');
      }
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
