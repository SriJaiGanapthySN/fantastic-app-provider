import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';
import 'package:fantastic_app_riverpod/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/providers/chat_state_provider.dart';

class MessageBuilder extends ConsumerStatefulWidget {
  final ChatMessageData messageData;
  final TickerProvider tickerProvider;

  const MessageBuilder({
    Key? key,
    required this.messageData,
    required this.tickerProvider,
  }) : super(key: key);

  @override
  ConsumerState<MessageBuilder> createState() => _MessageBuilderState();
}

class _MessageBuilderState extends ConsumerState<MessageBuilder> {
  late MessageFactory messageFactory;

  @override
  void initState() {
    super.initState();
    messageFactory = MessageFactory(widget.tickerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final messageData = widget.messageData;
    final shouldAnimate =
        !messageData.hasAnimated; // Only animate if not already animated

    Widget messageWidget;

    switch (messageData.type) {
      case ChatMessageType.userMessage:
        messageWidget = messageFactory.createUserMessage(
          messageText: messageData.text,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate) {
              // Mark as animated only if it was animating
              ref
                  .read(chatProvider.notifier)
                  .markMessageAsAnimated(messageData.id);
            }
          },
        );
        break;

      case ChatMessageType.cardMessage:
        messageWidget = messageFactory.createCardMessage(
          isQuestion: messageData.isQuestion,
          apiResponse: messageData.text,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate) {
              // Mark as animated only if it was animating
              ref
                  .read(chatProvider.notifier)
                  .markMessageAsAnimated(messageData.id);
            }
          },
        );
        break;

      case ChatMessageType.audioMessage:
        messageWidget = messageFactory.createAudioMessage(
          messageText: messageData.text,
          audioUrl: messageData.audioUrl ?? '',
          isUser: messageData.isUser,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate) {
              // Mark as animated only if it was animating
              ref
                  .read(chatProvider.notifier)
                  .markMessageAsAnimated(messageData.id);
            }
          },
        );
        break;
    }

    return messageWidget;
  }
}
