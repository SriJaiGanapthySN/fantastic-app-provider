import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class MessageInputBar extends ConsumerStatefulWidget {
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
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes locally to avoid provider rebuilds
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final newHasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != newHasText) {
      setState(() {
        _hasText = newHasText;
      });
    }

    // Don't update provider for every text change to avoid excessive rebuilds
    // Text state is handled locally, provider only needs to know about major state changes
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -15), // Move the input bar 20 pixels up
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            if (!widget.isSendingMessage)
              GestureDetector(
                onTap: () {
                  print('Mic button tapped');
                  widget.toggleMessageBoxVisibility();
                },
                // Only allow long press when message box is not visible
                onLongPressStart:
                    widget.isMessageBoxVisible ? null : widget.onLongPressStart,
                onLongPressEnd:
                    widget.isMessageBoxVisible ? null : widget.onLongPressEnd,
                onLongPressDown: widget.isMessageBoxVisible ? null : (_) {},
                onLongPressUp: widget.isMessageBoxVisible ? null : () {},
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
                  child: widget.isMessageBoxVisible || widget.isLongPressing
                      ? const Icon(Icons.close, color: Colors.white)
                      : const Icon(Icons.blur_circular,
                          color: Colors.white, size: 45),
                ),
              ),
            const SizedBox(width: 8),
            if (widget.isMessageBoxVisible && !widget.isSendingMessage)
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 50),
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
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      key: const ValueKey('chat_input_field'),
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      enabled: true,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        print('TextField onChanged: $value');
                      },
                      onTap: () {
                        print('TextField tapped');
                      },
                      onFieldSubmitted: (value) {
                        print('TextField submitted: $value');
                        if (value.trim().isNotEmpty) {
                          widget.sendMessage(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            if (widget.isMessageBoxVisible && !widget.isSendingMessage)
              IconButton(
                onPressed: _hasText
                    ? () => widget.sendMessage(widget.controller.text)
                    : null,
                icon: const Icon(Icons.send),
                color: _hasText ? Colors.white : Colors.white38,
              ),
            if (!widget.isMessageBoxVisible)
              Container(
                margin: const EdgeInsets.only(left: 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 2000),
                  opacity: widget.opacity,
                  child: Row(
                    children: [
                      if (!widget.isLongPressing) ...[
                        const Icon(
                          Icons.circle_sharp,
                          color: Color(0xFFA715E9),
                          size: 6,
                        ),
                        const SizedBox(width: 2),
                        TextAnimator(
                          widget.displayText,
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
      ),
    );
  }
}
