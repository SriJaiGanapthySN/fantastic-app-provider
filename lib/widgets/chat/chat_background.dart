import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChatBackground extends StatelessWidget {
  final bool isThresholdReached;

  const ChatBackground({Key? key, required this.isThresholdReached})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (isThresholdReached)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Lottie.asset(
                'assets/animations/All Lottie/BG Glow Gradient/3 in 1/BG Glow Gradient.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ),
      ],
    );
  }
}
