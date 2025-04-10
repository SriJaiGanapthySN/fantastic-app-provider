import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyChatPlaceholder extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: shouldShowTextBox ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          child: Center(
            child: Lottie.asset(
              'assets/animations/BG small Blur.json',
              width: screenWidth / 0.9,
              height: screenHeight / 1.8,
              fit: BoxFit.fill,
              controller: mindController,
            ),
          ),
        ),
        if (shouldShowTextBox)
          Center(
            child: AnimatedOpacity(
              opacity: showContainer && showMindText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: screenWidth / 2.15,
                  height: screenHeight / 13,
                  color: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    "What's on your mind?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
