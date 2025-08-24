import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/streaming_message_controller.dart';

class StreamingMessageBubble extends StatefulWidget {
  final Animation<Offset> animation;
  final AnimationController controller;
  final Alignment alignment;
  final Color bubbleColor;
  final Color textColor;
  final Function onAnimationComplete;
  final StreamingMessageController streamingController;

  const StreamingMessageBubble({
    super.key,
    required this.animation,
    required this.controller,
    required this.alignment,
    required this.bubbleColor,
    required this.textColor,
    required this.onAnimationComplete,
    required this.streamingController,
  });

  @override
  State<StreamingMessageBubble> createState() => _StreamingMessageBubbleState();
}

class _StreamingMessageBubbleState extends State<StreamingMessageBubble> {
  String _displayedText = '';
  bool _isComplete = false;
  StreamSubscription<String>? _textSubscription;
  StreamSubscription<bool>? _completionSubscription;

  @override
  void initState() {
    super.initState();
    
    // Listen to text chunk stream updates
    _textSubscription = widget.streamingController.textChunkStream.listen((chunk) {
      if (mounted) {
        setState(() {
          _displayedText += chunk;
        });
      }
    });

    // Listen to completion stream
    _completionSubscription = widget.streamingController.completionStream.listen((isComplete) {
      if (mounted && isComplete) {
        setState(() {
          _isComplete = true;
        });
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void dispose() {
    _textSubscription?.cancel();
    _completionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        alignment: widget.alignment,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.bubbleColor.withOpacity(0.7), // More translucent
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _displayedText,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
              if (!_isComplete)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TypingIndicator(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  __TypingIndicatorState createState() => __TypingIndicatorState();
}

class __TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
              child: Transform.scale(
                scale: 0.5 +
                    0.5 *
                        (1.0 -
                            (((_animation.value + index * 0.3) % 1.0 - 0.5)
                                    .abs() *
                                2)),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
