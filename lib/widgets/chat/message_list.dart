import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/models/chat_message_data.dart';
import 'package:fantastic_app_riverpod/widgets/chat/message_builder.dart';

class MessageList extends ConsumerWidget {
  final List<ChatMessageData> messageData;
  final ScrollController scrollController;
  final bool isLongPressing;
  final TickerProvider tickerProvider;

  const MessageList({
    Key? key,
    required this.messageData,
    required this.scrollController,
    required this.isLongPressing,
    required this.tickerProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: messageData.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets
                .zero, // Remove padding during voice input to prevent bubble movement
            child: MessageBuilder(
              messageData: messageData[index],
              tickerProvider: tickerProvider,
            ),
          );
        },
      ),
    );
  }
}
