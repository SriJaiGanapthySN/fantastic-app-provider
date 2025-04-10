import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class VoiceInputOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (!isLongPressing) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: screenHeight * 0.4,
              alignment: Alignment.bottomCenter,
              child: Lottie.asset(
                "assets/animations/All Lottie/Down Ripple/Ripple.json",
                width: MediaQuery.of(context).size.width,
                height: screenHeight * 0.25,
                fit: BoxFit.fill,
                repeat: true,
                animate: true,
                controller: rippleController,
              ),
            ),
            if (voiceText.isNotEmpty)
              Positioned(
                bottom: screenHeight * 0.08,
                left: 16,
                right: 16,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextAnimator(
                    voiceText,
                    incomingEffect:
                        WidgetTransitionEffects.incomingSlideInFromBottom(),
                    outgoingEffect:
                        WidgetTransitionEffects.outgoingSlideOutToBottom(),
                    atRestEffect: WidgetRestingEffects.wave(
                      numberOfPlays: 1,
                      effectStrength: 0.2,
                    ),
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
