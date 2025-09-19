import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class AnimatedCardMessage extends StatefulWidget {
  final bool isQuestion;
  final String apiResponse;
  final Function()? onAnimationComplete;
  final bool shouldAnimate; // Add flag to control animation

  const AnimatedCardMessage({
    Key? key,
    this.isQuestion = false,
    this.apiResponse = "Here is a reference to the card",
    this.onAnimationComplete,
    this.shouldAnimate = true, // Default to true for new messages
  }) : super(key: key);

  @override
  State<AnimatedCardMessage> createState() => _AnimatedCardMessageState();
}

class _AnimatedCardMessageState extends State<AnimatedCardMessage>
    with SingleTickerProviderStateMixin {
  double iconOpacity = 0.0;
  bool repeatGlow = true;
  bool isGlowVisible = true;
  bool isBoxVisible = false;
  double opacityLevel = 1.0;
  bool isQuesAnimVisible = true;
  bool showLocalSparkles =
      false; // New: Small sparkle animation at bubble location

  // ============= COMMENTED IMAGE VARIABLES =============
  // Uncomment these if you want to restore image functionality:
  // bool applyBlur = false;
  // double opacity = 0.0;
  // late AnimationController imageController;
  // ====================================================

  @override
  void initState() {
    super.initState();

    // ============= COMMENTED IMAGE CONTROLLER SETUP =============
    // Uncomment these if you want to restore image functionality:
    /*
    imageController = AnimationController(vsync: this);

    imageController.addListener(() {
      setState(() {
        opacity = imageController.value;
      });
    });

    imageController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          applyBlur = true;
        });
      }
    });
    */
    // ============================================================

    // Initialize animation states
    print('🚀 AnimatedCardMessage initialized');
    print('📝 Is Question: ${widget.isQuestion}');
    print('💬 API Response length: ${widget.apiResponse.length}');

    isQuesAnimVisible = widget.isQuestion;
    isGlowVisible = !widget.isQuestion;

    print(
        '🎯 Initial states - isGlowVisible: $isGlowVisible, isQuesAnimVisible: $isQuesAnimVisible');

    // Begin animations sequence only if shouldAnimate is true
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.shouldAnimate) {
        _startAnimations();
      } else {
        // For existing messages, skip animations and show final state
        _showFinalState();
      }
    });
  }

  void _startAnimations() {
    // Calculate animation duration based on API response length
    int responseLength = widget.apiResponse.length;
    int estimatedReadingTimeMs = (responseLength * 50)
        .clamp(3000, 8000); // 50ms per character, min 3s, max 8s

    // Show localized sparkles first - like Claude's thinking animation
    Future.delayed(Duration(milliseconds: 1500), () {
      // Increased from 500 to 1500ms
      if (mounted) {
        print('🔮 Starting sparkle animation');
        setState(() {
          showLocalSparkles = true;
        });
      }
    });

    // Initial fade sequence
    Future.delayed(Duration(milliseconds: 3100), () {
      // Increased from 2100 to 3100ms
      if (mounted) {
        print('🌟 Starting background fade');
        setState(() {
          _decreaseOpacity();
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              print('✨ Hiding background and sparkles');
              setState(() {
                isGlowVisible = false;
                showLocalSparkles =
                    false; // Hide sparkles when main animation starts
              });
            }
          });
        });
      }
    });

    // Box visibility - start showing the box with increased delay
    Future.delayed(Duration(milliseconds: widget.isQuestion ? 3800 : 3400), () {
      // Increased by 1000ms
      if (mounted) {
        print('💬 Showing message box');
        setState(() {
          isBoxVisible = true;

          // Keep border animations running until message is likely complete
          Future.delayed(Duration(milliseconds: estimatedReadingTimeMs), () {
            if (mounted) {
              print('🎯 Animation complete');
              setState(() {
                iconOpacity = 1.0;
                repeatGlow = false;
                isQuesAnimVisible = false;
              });
              if (widget.onAnimationComplete != null) {
                widget.onAnimationComplete!();
              }
            }
          });
        });
      }
    });
  }

  void _showFinalState() {
    // Set final state immediately for existing messages
    setState(() {
      iconOpacity = 1.0;
      repeatGlow = false;
      isGlowVisible = false;
      isBoxVisible = true;
      opacityLevel = 0.0; // Fully faded
      isQuesAnimVisible = false;
      showLocalSparkles = false;
    });

    // Call completion callback immediately
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  void _decreaseOpacity() async {
    print('🔄 Starting opacity decrease animation');
    for (double i = 1.0; i >= 0.0; i -= 0.05) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          opacityLevel = i;
        });
        if (i <= 0.05) {
          print('⭕ Background animation opacity reached minimum');
        }
      }
    }
    print('✅ Background opacity animation complete');
  }

  @override
  void dispose() {
    // ============= COMMENTED IMAGE CONTROLLER DISPOSE =============
    // Uncomment this if you want to restore image functionality:
    // imageController.dispose();
    // ==============================================================
    super.dispose();
  }

  // Helper methods for responsive sizing
  double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    // Base the font size on the width for consistency
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * screenWidth / 375; // 375 is baseline for iPhone X
  }

  double getResponsivePadding(BuildContext context, double value) {
    double screenWidth = MediaQuery.of(context).size.width;
    return value * screenWidth / 375;
  }

  // Calculate precise text height for dynamic bubble sizing
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

    // Calculate available width for text (accounting for padding and margins)
    double availableWidth = getResponsiveWidth(context, 0.87) -
        getResponsivePadding(context, 18) -
        getResponsivePadding(context, 12) -
        getResponsivePadding(context, 5) -
        getResponsivePadding(context, 10);

    textPainter.layout(maxWidth: availableWidth);
    return textPainter.size.height;
  }

  // Calculate dynamic height based on actual text content
  double calculateDynamicHeight(BuildContext context) {
    // Get actual text height
    double textHeight = calculateTextHeight(context, widget.apiResponse);

    // Add padding for top, bottom margins and some breathing space
    double totalPadding = getResponsivePadding(context, 12) + // top padding
        getResponsivePadding(context, 12) + // bottom padding
        getResponsivePadding(context, 10) + // top margin
        getResponsivePadding(context, 20); // extra breathing space

    double finalHeight = textHeight + totalPadding;

    // Set reasonable bounds
    double minHeight = getResponsiveHeight(context, 0.08); // Smaller minimum
    double maxHeight = getResponsiveHeight(context, 0.40); // Reasonable maximum

    return finalHeight.clamp(minHeight, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: getResponsivePadding(context, 3),
        horizontal: getResponsivePadding(context, 10),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            if (isGlowVisible || isQuesAnimVisible)
              AnimatedOpacity(
                opacity: opacityLevel,
                duration: Duration(milliseconds: widget.isQuestion ? 170 : 300),
                child: Lottie.asset(
                  widget.isQuestion
                      ? "assets/animations/QnA/2. Circle/data.json"
                      : 'assets/animations/All Lottie/Glowing Star/Image Preload Gradient.json',
                  width: widget.isQuestion
                      ? getResponsiveWidth(context, 0.65)
                      : getResponsiveWidth(context, 0.8),
                  height: widget.isQuestion
                      ? getResponsiveHeight(context, 0.25)
                      : getResponsiveHeight(context, 0.4),
                  fit: BoxFit.cover,
                  repeat: true,
                  animate: true,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Error loading background animation: $error');
                    return SizedBox
                        .shrink(); // Just hide the animation if it fails
                  },
                ),
              ),

            // ============= LOCALIZED SPARKLE ANIMATION =============
            // Small sparkle animation at bubble location (like Claude's thinking)
            if (showLocalSparkles)
              Positioned(
                left:
                    getResponsiveWidth(context, 0.05), // Small offset from left
                top:
                    getResponsiveHeight(context, 0.02), // Small offset from top
                child: AnimatedOpacity(
                  opacity: showLocalSparkles ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: SizedBox(
                    width: getResponsiveWidth(context, 0.20), // Small width
                    height: getResponsiveHeight(context, 0.10), // Small height
                    child: Lottie.asset(
                      'assets/animations/All Lottie/BG small Blur/BG small Blur.json',
                      width: getResponsiveWidth(context, 0.20),
                      height: getResponsiveHeight(context, 0.10),
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Error loading sparkle animation: $error');
                        print('❌ Stack trace: $stackTrace');
                        return SizedBox
                            .shrink(); // Just hide the sparkles if they fail to load
                      },
                    ),
                  ),
                ),
              ),
            // ======================================================
            if (isBoxVisible) ...[
              // Dynamic height based on actual text content
              LayoutBuilder(
                builder: (context, constraints) {
                  double dynamicHeight = calculateDynamicHeight(context);

                  return Lottie.asset(
                    "assets/animations/Inner+Outerbox+Glow/Outerbox/Outerbox.json",
                    width: getResponsiveWidth(context, 0.87),
                    height: dynamicHeight,
                    fit: BoxFit.fill,
                    repeat: false,
                  );
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double dynamicHeight = calculateDynamicHeight(context);

                  return Lottie.asset(
                    "assets/animations/Inner+Outerbox+Glow/Outer Glow/Outerbox.json",
                    width: getResponsiveWidth(context, 0.87),
                    height: dynamicHeight,
                    fit: BoxFit.fill,
                    repeat: repeatGlow,
                  );
                },
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
                            widget.apiResponse,
                            incomingEffect: WidgetTransitionEffects(
                                blur: const Offset(10, 10),
                                duration: const Duration(milliseconds: 800)),
                            outgoingEffect: WidgetTransitionEffects(
                                blur: const Offset(10, 10)),
                            atRestEffect: WidgetRestingEffects.wave(
                                effectStrength: 0.2,
                                duration: Duration(milliseconds: 750),
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
                            maxLines: null, // Allow unlimited lines
                          ),
                        ),
                      ),

                      // ============= COMMENTED IMAGE SECTION =============
                      // Uncomment below to add image section back to message cards
                      /*
                      Container(
                        margin: EdgeInsets.only(
                          top: getResponsivePadding(context, 10),
                          left: getResponsivePadding(context, 10),
                        ),
                        child: CardImageSection(
                          imageController: imageController,
                          opacity: opacity,
                          applyBlur: applyBlur,
                          getResponsiveWidth: getResponsiveWidth,
                          getResponsiveHeight: getResponsiveHeight,
                          getResponsiveFontSize: getResponsiveFontSize,
                        ),
                      ),
                      */
                      // ===================================================
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ============= COMMENTED IMAGE SECTION CLASS =============
// Uncomment below class to enable image functionality in message cards
/*
class CardImageSection extends StatelessWidget {
  final AnimationController imageController;
  final double opacity;
  final bool applyBlur;
  final Function(BuildContext, double) getResponsiveWidth;
  final Function(BuildContext, double) getResponsiveHeight;
  final Function(BuildContext, double) getResponsiveFontSize;

  const CardImageSection({
    super.key,
    required this.imageController,
    required this.opacity,
    required this.applyBlur,
    required this.getResponsiveWidth,
    required this.getResponsiveHeight,
    required this.getResponsiveFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(getResponsiveWidth(context, 0.032)),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            opacity: ((opacity - 0.3) <= 0.0) ? 0 : opacity - 0.3,
            child: Image.asset(
              'assets/images/image (1).png',
              width: getResponsiveWidth(context, 0.7),
              height: getResponsiveHeight(context, 0.231),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Lottie.asset(
            'assets/animations/gradient.json',
            fit: BoxFit.cover,
            repeat: true,
            controller: imageController,
            onLoaded: (composition) {
              imageController
                ..duration = composition.duration
                ..forward();
            },
          ),
        ),
        if (applyBlur)
          Positioned(
            bottom:
                getResponsiveHeight(context, 0.01), // ~10px on 1000px height
            left: getResponsiveWidth(context, 0.053), // ~20px on 375px width
            right: getResponsiveWidth(context, 0.053), // ~20px on 375px width
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 800),
              curve: Curves.easeIn,
              opacity: opacity >= 0.8 ? 1.0 : 0.0,
              child: AnimatedBuilder(
                animation: imageController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0,
                        imageController.value < 0.8
                            ? getResponsiveHeight(context, 0.02)
                            : 0), // ~20px on 1000px height
                    child: Text(
                      "Dolphins Doing a Backflip in the Ocean",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
*/
// =========================================================
