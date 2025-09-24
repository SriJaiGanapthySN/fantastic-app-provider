import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import 'animated_object_card_message.dart';
import '../../models/responsemodel.dart';
import '../../services/bracketed_content_service.dart';

class AnimatedCardMessage extends ConsumerStatefulWidget {
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
    this.shouldAnimate = true, // Default to true for new messages
    this.onAnimationComplete,
  });

  @override
  ConsumerState<AnimatedCardMessage> createState() =>
      _AnimatedCardMessageState();
}

class _AnimatedCardMessageState extends ConsumerState<AnimatedCardMessage>
    with SingleTickerProviderStateMixin {
  double iconOpacity = 0.0;
  bool repeatGlow = true;
  bool isGlowVisible = true;
  bool isBoxVisible = false;
  double opacityLevel = 1.0;
  bool isQuesAnimVisible = true;
  bool showLocalSparkles =
      false; // New: Small sparkle animation at bubble location

  // ============= IMAGE VARIABLES FOR CONTENT CARDS =============
  bool applyBlur = false;
  double opacity = 0.0;
  late AnimationController imageController;
  // ===============================================================

  // Store the parsed response model and display text
  late ChatResponseModel _parsedResponse;
  late String _displayText;

  @override
  void initState() {
    super.initState();

    // Parse the API response to extract bracketed content and get display text
    _parsedResponse = ChatResponseModel.fromRawResponse(widget.apiResponse);
    _displayText = _parsedResponse.displayText;

    // Store the parsed response model for this message ID
    if (_parsedResponse.hasExtractedFields) {
      BracketedContentService.storeResponseModel(widget.id, _parsedResponse);
    }

    print('🔍 Parsed response for message ${widget.id}:');
    print('  - Original: "${widget.apiResponse}"');
    print('  - Original length: ${widget.apiResponse.length}');
    print('  - Display text: "$_displayText"');
    print('  - Display text length: ${_displayText.length}');
    print('  - Bracketed content: ${_parsedResponse.rawBracketedContent}');
    if (_parsedResponse.hasObjectId) {
      print('  - Object ID: ${_parsedResponse.objectId}');
    }
    if (_parsedResponse.hasType) {
      print('  - Type: ${_parsedResponse.type}');
    }
    print(
        '  - Stored in BracketedContentService: ${_parsedResponse.hasExtractedFields}');

    // Check for empty response issue
    if (widget.apiResponse.isEmpty) {
      print('⚠️ WARNING: API response is completely empty!');
    } else if (_displayText.isEmpty) {
      print(
          '⚠️ WARNING: Display text is empty after parsing! Raw response: "${widget.apiResponse}"');
    }

    // ============= IMAGE CONTROLLER SETUP FOR CONTENT CARDS =============
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
    // =====================================================================

    // Initialize animation states
    print('🚀 AnimatedCardMessage initialized');
    print('📝 Is Question: ${widget.isQuestion}');
    print('💬 Display text length: ${_displayText.length}');

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
    // Calculate animation duration closer to TextAnimator timings
    // TextAnimator config: characterDelay: 10ms, spaceDelay: 100ms,
    // incomingEffect: 800ms, atRestEffect: 750ms (plays once)
    final int responseLength = _displayText.length;
    final int spacesCount = RegExp(r'\s').allMatches(_displayText).length;
    const int incomingMs = 800;
    const int atRestMs = 750;
    const int perCharMs = 10;
    const int perSpaceMs = 100;

    int computedMs = incomingMs +
        atRestMs +
        (responseLength * perCharMs) +
        (spacesCount * perSpaceMs) +
        200; // small buffer

    int estimatedReadingTimeMs = computedMs.clamp(2500, 20000);

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
    // ============= IMAGE CONTROLLER DISPOSE FOR CONTENT CARDS =============
    imageController.dispose();
    // =======================================================================
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
    // Get actual text height using the display text (without brackets)
    double textHeight = calculateTextHeight(context, _displayText);

    // Add padding for top, bottom margins and extra breathing space to fix overflow
    double totalPadding =
        getResponsivePadding(context, 15) + // increased top padding
            getResponsivePadding(context, 15) + // increased bottom padding
            getResponsivePadding(context, 12) + // top margin
            getResponsivePadding(
                context, 30); // increased breathing space for overflow fix

    double finalHeight = textHeight + totalPadding;

    // Set reasonable bounds - increased max height to prevent overflow
    double minHeight = getResponsiveHeight(context, 0.10);
    double maxHeight = getResponsiveHeight(
        context, 0.85); // Increased from 0.65 to 0.85 to fix overflow error

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
          alignment: Alignment.center,
          children: [
            if (isGlowVisible || isQuesAnimVisible)
              AnimatedOpacity(
                opacity: opacityLevel,
                duration: Duration(milliseconds: widget.isQuestion ? 170 : 300),
                child: Lottie.asset(
                  widget.isQuestion
                      ? "assets/animations/QnA/2. circle/data.json" // Fixed case: circle not Circle
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
              // Dynamic height based on actual text content, with smooth size transitions
              LayoutBuilder(
                builder: (context, constraints) {
                  double dynamicHeight = calculateDynamicHeight(context);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: getResponsiveWidth(context, 0.87),
                    height: dynamicHeight,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Lottie.asset(
                        "assets/animations/Inner+Outerbox+Glow/Outerbox/Outerbox.json",
                        fit: BoxFit.fill,
                        repeat: false,
                      ),
                    ),
                  );
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double dynamicHeight = calculateDynamicHeight(context);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: getResponsiveWidth(context, 0.87),
                    height: dynamicHeight,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Lottie.asset(
                        "assets/animations/Inner+Outerbox+Glow/Outer Glow/Outerbox.json",
                        fit: BoxFit.fill,
                        repeat: repeatGlow,
                      ),
                    ),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: getResponsivePadding(context, 10),
                            left: getResponsivePadding(context, 5),
                            right: getResponsivePadding(context, 10),
                          ),
                          child: _displayText.isNotEmpty
                              ? TextAnimator(
                                  _displayText, // Use display text without brackets
                                  incomingEffect: WidgetTransitionEffects(
                                      blur: const Offset(10, 10),
                                      duration:
                                          const Duration(milliseconds: 800)),
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
                                    fontSize:
                                        getResponsiveFontSize(context, 14),
                                    color: Colors.white,
                                  )),
                                  textAlign: TextAlign.left,
                                  initialDelay: const Duration(milliseconds: 0),
                                  spaceDelay: const Duration(milliseconds: 100),
                                  characterDelay:
                                      const Duration(milliseconds: 10),
                                  maxLines: null, // Allow unlimited lines
                                )
                              : Text(
                                  "Response received but content is empty. Please try again.",
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      fontFamily: "Original",
                                      letterSpacing: 1,
                                      fontSize:
                                          getResponsiveFontSize(context, 14),
                                      color: Colors.white.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                        ),

                        // ============= IMAGE SECTION FOR CONTENT CARDS =============
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
                        // ============================================================
                      ],
                    ),
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
