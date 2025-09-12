import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class VoiceInputOverlay extends StatefulWidget {
  final AnimationController rippleController;
  final String voiceText;
  final bool isLongPressing;

  const VoiceInputOverlay({
    Key? key,
    required this.rippleController,
    required this.voiceText,
    required this.isLongPressing,
  }) : super(key: key);

  @override
  State<VoiceInputOverlay> createState() => _VoiceInputOverlayState();
}

class _VoiceInputOverlayState extends State<VoiceInputOverlay>
    with TickerProviderStateMixin {
  late AnimationController _messageTransitionController;
  late AnimationController _waveController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;
  bool _showMessageBubble = false;
  String _finalText = '';

  @override
  void initState() {
    super.initState();

    // Controller for transitioning to message bubble
    _messageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controller for wave animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Slide animation for message bubble
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _messageTransitionController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for message bubble
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageTransitionController,
      curve: Curves.elasticOut,
    ));

    // Wave animation for text
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(VoiceInputOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start wave animation when speaking
    if (widget.isLongPressing && !oldWidget.isLongPressing) {
      _waveController.repeat(reverse: true);
    }

    // Stop wave animation when not speaking
    if (!widget.isLongPressing && oldWidget.isLongPressing) {
      _waveController.stop();
      _waveController.reset();
    }

    // Handle transition from voice input to message bubble
    if (oldWidget.isLongPressing &&
        !widget.isLongPressing &&
        widget.voiceText.isNotEmpty) {
      _startMessageBubbleTransition();
    }

    // Reset when starting new voice input
    if (!oldWidget.isLongPressing && widget.isLongPressing) {
      _resetToVoiceInput();
    }
  }

  void _startMessageBubbleTransition() {
    setState(() {
      _finalText = widget.voiceText;
      _showMessageBubble = true;
    });
    _messageTransitionController.forward();

    // Hide the message bubble after showing it briefly
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _messageTransitionController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showMessageBubble = false;
              _finalText = '';
            });
          }
        });
      }
    });
  }

  void _resetToVoiceInput() {
    _messageTransitionController.reset();
    setState(() {
      _showMessageBubble = false;
      _finalText = '';
    });
  }

  @override
  void dispose() {
    _messageTransitionController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Widget _buildWaveText() {
    if (widget.voiceText.isEmpty) return const SizedBox.shrink();

    final words = widget.voiceText.split(' ');

    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Wrap(
          alignment: WrapAlignment.center,
          children: words.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            final delay = index * 0.1;
            final animValue = (_waveAnimation.value + delay) % 1.0;
            final waveOffset = sin(animValue * 2 * pi) * 15;

            return Transform.translate(
              offset: Offset(0, waveOffset),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  word,
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMessageBubble() {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _finalText,
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (!widget.isLongPressing && !_showMessageBubble) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Stack(
        children: [
          // Your Lottie ripple animation - positioned at the bottom
          if (widget.isLongPressing)
            Container(
              height: screenHeight * 0.6,
              alignment: Alignment.bottomCenter,
              child: Lottie.asset(
                "assets/animations/All Lottie/Down Ripple/Ripple.json",
                width: screenWidth,
                height: screenHeight * 0.25,
                fit: BoxFit.fill,
                repeat: true,
                animate: true,
                controller: widget.rippleController,
                options: LottieOptions(
                  enableMergePaths: true,
                ),
                frameRate: FrameRate.composition,
              ),
            ),

          // Wavy text display (white, no background)
          if (widget.isLongPressing && widget.voiceText.isNotEmpty)
            Positioned(
              bottom: screenHeight * 0.15,
              left: 20,
              right: 20,
              child: _buildWaveText(),
            ),

          // Message bubble transition
          if (_showMessageBubble)
            Positioned(
              bottom: screenHeight * 0.12,
              left: 0,
              right: 0,
              child: _buildMessageBubble(),
            ),
        ],
      ),
    );
  }
}
