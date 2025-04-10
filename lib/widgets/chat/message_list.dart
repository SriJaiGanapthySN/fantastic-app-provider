import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<Widget> messages;
  final ScrollController scrollController;
  final bool isLongPressing;

  const MessageList({
    Key? key,
    required this.messages,
    required this.scrollController,
    required this.isLongPressing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              bottom: (index == 0 && isLongPressing)
                  ? MediaQuery.of(context).size.height * 0.15
                  : 0,
            ),
            child: messages[index],
          );
        },
      ),
    );
  }
}
