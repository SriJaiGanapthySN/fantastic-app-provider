import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class MessageInputBar extends StatelessWidget {
  final bool isMessageBoxVisible;
  final bool isSendingMessage;
  final bool isLongPressing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final double opacity;
  final String displayText;
  final VoidCallback toggleMessageBoxVisibility;
  final Function(LongPressStartDetails) onLongPressStart;
  final Function(LongPressEndDetails) onLongPressEnd;
  final Function(String) sendMessage;

  const MessageInputBar({
    super.key,
    required this.isMessageBoxVisible,
    required this.isSendingMessage,
    required this.isLongPressing,
    required this.controller,
    required this.focusNode,
    required this.opacity,
    required this.displayText,
    required this.toggleMessageBoxVisibility,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          if (!isSendingMessage)
            GestureDetector(
              onTap: toggleMessageBoxVisibility,
              onLongPressStart: onLongPressStart,
              onLongPressEnd: onLongPressEnd,
              onLongPressDown: (_) {},
              onLongPressUp: () {},
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isMessageBoxVisible || isLongPressing
                    ? const Icon(Icons.close, color: Colors.white)
                    : const Icon(Icons.blur_circular,
                        color: Colors.white, size: 45),
              ),
            ),
          const SizedBox(width: 8),
          if (isMessageBoxVisible && !isSendingMessage)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (isMessageBoxVisible && controller.text.isNotEmpty)
            IconButton(
              onPressed: () => sendMessage(controller.text),
              icon: const Icon(Icons.send),
              color: Colors.white54,
            ),
          if (!isMessageBoxVisible)
            Container(
              margin: const EdgeInsets.only(left: 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 2000),
                opacity: opacity,
                child: Row(
                  children: [
                    if (!isLongPressing) ...[
                      const Icon(
                        Icons.circle_sharp,
                        color: Color(0xFFA715E9),
                        size: 6,
                      ),
                      const SizedBox(width: 2),
                      TextAnimator(
                        displayText,
                        incomingEffect: WidgetTransitionEffects(
                          blur: const Offset(10, 10),
                          duration: const Duration(milliseconds: 500),
                        ),
                        outgoingEffect: WidgetTransitionEffects(
                          blur: const Offset(10, 10),
                        ),
                        atRestEffect: WidgetRestingEffects.wave(
                          effectStrength: 0.2,
                          duration: const Duration(milliseconds: 750),
                          numberOfPlays: 1,
                        ),
                        style: const TextStyle(
                          fontFamily: "Original",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                        initialDelay: const Duration(milliseconds: 0),
                        spaceDelay: const Duration(milliseconds: 100),
                        characterDelay: const Duration(milliseconds: 10),
                      ),
                    ]
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
