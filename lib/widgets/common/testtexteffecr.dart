import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter

class BlurFadeAndColorTextEffect extends StatefulWidget {
  final String text;

  const BlurFadeAndColorTextEffect({super.key, required this.text});

  @override
  _BlurFadeAndColorTextEffectState createState() =>
      _BlurFadeAndColorTextEffectState();
}

class _BlurFadeAndColorTextEffectState extends State<BlurFadeAndColorTextEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _offsetAnimation; // Animation for vertical offset

  List<String> words = [];
  int currentWordIndex = 0;

  @override
  void initState() {
    super.initState();

    // Split the text into words
    words = widget.text.split(' ');

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: 250), // Duration for each word's animation
    );

    // Define the blur animation
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);

    // Define the fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Define the color animation
    _colorAnimation = ColorTween(
      begin: Colors.blue.shade900, // Dark blue
      end: Colors.white, // Light white
    ).animate(_controller);

    // Define the offset animation (word comes from below)
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 1.0), // Start from below (y = 1.0)
      end: Offset(0, 0.0), // Settle in place (y = 0.0)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Smooth easing curve
    ));

    // Start the animation for the first word
    _startWordAnimation();
  }

  void _startWordAnimation() {
    if (currentWordIndex < words.length) {
      _controller.forward(from: 0.0).then((_) {
        // Move to the next word after the current animation completes
        setState(() {
          currentWordIndex++;
        });
        if (currentWordIndex < words.length) {
          _startWordAnimation(); // Start animation for the next word
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _blurAnimation.value, // Horizontal blur
              sigmaY: _blurAnimation.value, // Vertical blur
            ),
            child: Container(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  children: words.asMap().entries.map((entry) {
                    int index = entry.key;
                    String word = entry.value;

                    // Apply animation only to the current word
                    if (index == currentWordIndex) {
                      return TextSpan(
                        text: '$word ',
                        style: TextStyle(
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                          color: _colorAnimation.value, // Animated font color
                        ),
                      );
                    } else if (index < currentWordIndex) {
                      // Previous words are fully white and static
                      return TextSpan(
                        text: '$word ',
                        style: TextStyle(
                          fontSize: 14,

                          // fontWeight: FontWeight.bold,
                          color: Colors.white, // Fully white
                        ),
                      );
                    } else {
                      // Future words are not displayed yet
                      return TextSpan();
                    }
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
