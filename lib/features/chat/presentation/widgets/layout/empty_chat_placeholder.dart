import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyChatPlaceholder extends StatefulWidget {
  final bool shouldShowTextBox;
  final bool showContainer;
  final bool showMindText;
  final AnimationController mindController;

  const EmptyChatPlaceholder({
    super.key,
    required this.shouldShowTextBox,
    required this.showContainer,
    required this.showMindText,
    required this.mindController,
  });

  @override
  State<EmptyChatPlaceholder> createState() => _EmptyChatPlaceholderState();
}

class _EmptyChatPlaceholderState extends State<EmptyChatPlaceholder> {
  bool? _lastShowContainer;
  bool? _lastShowMindText;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Only print debug info when values actually change
    if (_lastShowContainer != widget.showContainer ||
        _lastShowMindText != widget.showMindText) {
      print(
          'EmptyChatPlaceholder state changed: container=${widget.showContainer}, mind=${widget.showMindText}');
      _lastShowContainer = widget.showContainer;
      _lastShowMindText = widget.showMindText;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Stack(
        children: [
          // Animation always visible but with opacity controlled
          Center(
            child: AnimatedOpacity(
              opacity: 1.0, // Always visible from the start
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              child: Lottie.asset(
                'assets/animations/emptychat.json',
                width: screenWidth / 0.9,
                height: screenHeight / 1.8,
                fit: BoxFit.fill,
                controller: widget.mindController,
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: widget.showContainer && widget.showMindText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: screenWidth / 2.15,
                  height: screenHeight / 13,
                  color: Colors.white.withOpacity(0.25),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    "What's on your mind?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: screenWidth * 0.031,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
