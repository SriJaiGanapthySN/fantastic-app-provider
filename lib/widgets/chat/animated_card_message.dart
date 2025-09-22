import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:fantastic_app_riverpod/providers/animated_card_provider.dart';

class AnimatedCardMessage extends ConsumerWidget {
  final String id;
  final String apiResponse;
  final bool isQuestion;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  const AnimatedCardMessage({
    super.key,
    required this.id,
    required this.apiResponse,
    required this.isQuestion,
    required this.shouldAnimate,
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerArgs = AnimatedCardProviderArgs(
      id: id,
      shouldAnimate: shouldAnimate,
      onAnimationComplete: onAnimationComplete,
    );
    final animationState = ref.watch(animatedCardProvider(providerArgs));

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: getResponsivePadding(context, 3),
        horizontal: getResponsivePadding(context, 10),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The main content (box and text)
            AnimatedOpacity(
              opacity: animationState.isContentVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _buildMessageContent(context),
            ),
            // The sparkle animation
            if (animationState.showSparkle)
              Lottie.asset(
                'assets/animations/All Lottie/Glowing Star/Image Preload Gradient.json',
                width: getResponsiveWidth(context, 0.8),
                height: getResponsiveHeight(context, 0.4),
                fit: BoxFit.contain,
                repeat: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    double dynamicHeight = calculateDynamicHeight(context);
    return Stack(
      children: [
        Lottie.asset(
          "assets/animations/Inner+Outerbox+Glow/Outerbox/Outerbox.json",
          width: getResponsiveWidth(context, 0.87),
          height: dynamicHeight,
          fit: BoxFit.fill,
          repeat: false,
        ),
        Lottie.asset(
          "assets/animations/Inner+Outerbox+Glow/Outer Glow/Outerbox.json",
          width: getResponsiveWidth(context, 0.87),
          height: dynamicHeight,
          fit: BoxFit.fill,
          repeat: true, // Keep the glow repeating
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(
              top: getResponsivePadding(context, 12),
              left: getResponsivePadding(context, 18),
              right: getResponsivePadding(context, 12),
              bottom: getResponsivePadding(context, 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: getResponsivePadding(context, 10),
                      left: getResponsivePadding(context, 5),
                      right: getResponsivePadding(context, 10),
                    ),
                    child: TextAnimator(
                      apiResponse,
                      incomingEffect: WidgetTransitionEffects(
                          blur: const Offset(10, 10),
                          duration: const Duration(milliseconds: 800)),
                      atRestEffect: WidgetRestingEffects.wave(
                          effectStrength: 0.2,
                          duration: const Duration(milliseconds: 750),
                          numberOfPlays: 1),
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        fontFamily: "Original",
                        letterSpacing: 1,
                        fontSize: getResponsiveFontSize(context, 14),
                        color: Colors.white,
                      )),
                      textAlign: TextAlign.left,
                      initialDelay: const Duration(milliseconds: 0),
                      spaceDelay: const Duration(milliseconds: 100),
                      characterDelay: const Duration(milliseconds: 10),
                      maxLines: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ... (keep all helper methods like getResponsiveWidth, calculateTextHeight, etc.)
  double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * screenWidth / 375;
  }

  double getResponsivePadding(BuildContext context, double value) {
    double screenWidth = MediaQuery.of(context).size.width;
    return value * screenWidth / 375;
  }

  double calculateTextHeight(BuildContext context, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            fontFamily: "Original",
            letterSpacing: 1,
            fontSize: getResponsiveFontSize(context, 14),
            color: Colors.white,
          ),
        ),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );

    double availableWidth = getResponsiveWidth(context, 0.87) -
        getResponsivePadding(context, 18) -
        getResponsivePadding(context, 12) -
        getResponsivePadding(context, 5) -
        getResponsivePadding(context, 10);

    textPainter.layout(maxWidth: availableWidth);
    return textPainter.size.height;
  }

  double calculateDynamicHeight(BuildContext context) {
    double textHeight = calculateTextHeight(context, apiResponse);
    double totalPadding = getResponsivePadding(context, 12) +
        getResponsivePadding(context, 12) +
        getResponsivePadding(context, 10) +
        getResponsivePadding(context, 20);
    double finalHeight = textHeight + totalPadding;
    double minHeight = getResponsiveHeight(context, 0.08);
    double maxHeight = getResponsiveHeight(context, 0.40);
    return finalHeight.clamp(minHeight, maxHeight);
  }
}
