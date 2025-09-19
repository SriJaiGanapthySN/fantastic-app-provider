import 'package:fantastic_app_riverpod/widgets/chat/empty_chat_placeholder.dart';
import 'package:fantastic_app_riverpod/widgets/chat/message_input_bar.dart';
import 'package:fantastic_app_riverpod/widgets/chat/message_list.dart';
import 'package:fantastic_app_riverpod/widgets/chat/voice_input_overlay.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';
import 'package:flutter/material.dart';

class ChatContent extends StatelessWidget {
  final List<ChatMessageData> messageData;
  final List<Widget> messages; // Keep for backward compatibility
  final ScrollController scrollController;
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isMessageBoxVisible;
  final bool isSendingMessage;
  final bool isLongPressing;
  final AnimationController rippleController;
  final double opacity;
  final String displayText;
  final String voiceText;
  final bool shouldShowTextBox;
  final bool showMindText;
  final bool showContainer;
  final AnimationController mindController;
  final TickerProvider tickerProvider;
  final Function() toggleMessageBoxVisibility;
  final Function(LongPressStartDetails) onLongPressStart;
  final Function(LongPressEndDetails) onLongPressEnd;
  final Function(String) sendMessage;

  const ChatContent({
    super.key,
    required this.messageData,
    required this.messages,
    required this.scrollController,
    required this.textController,
    required this.focusNode,
    required this.isMessageBoxVisible,
    required this.isSendingMessage,
    required this.isLongPressing,
    required this.rippleController,
    required this.opacity,
    required this.displayText,
    required this.voiceText,
    required this.shouldShowTextBox,
    required this.showMindText,
    required this.showContainer,
    required this.mindController,
    required this.tickerProvider,
    required this.toggleMessageBoxVisibility,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Empty chat placeholder when no messages
        if (messageData.isEmpty)
          EmptyChatPlaceholder(
            shouldShowTextBox: shouldShowTextBox,
            showContainer: showContainer,
            showMindText: showMindText,
            mindController: mindController,
          ),

        Column(
          children: [
            // Messages list using new message data approach
            MessageList(
              messageData: messageData,
              scrollController: scrollController,
              isLongPressing: isLongPressing,
              tickerProvider: tickerProvider,
            ),
            // Message input bar component
            MessageInputBar(
              isMessageBoxVisible: isMessageBoxVisible,
              isSendingMessage: isSendingMessage,
              isLongPressing: isLongPressing,
              controller: textController,
              focusNode: focusNode,
              opacity: opacity,
              displayText: displayText,
              toggleMessageBoxVisibility: toggleMessageBoxVisibility,
              onLongPressStart: onLongPressStart,
              onLongPressEnd: onLongPressEnd,
              sendMessage: sendMessage,
            ),
          ],
        ),

        // Voice input overlay component
        VoiceInputOverlay(
          rippleController: rippleController,
          voiceText: voiceText,
          isLongPressing: isLongPressing,
          isMessageBoxVisible: isMessageBoxVisible,
        ),
      ],
    );
  }
}
