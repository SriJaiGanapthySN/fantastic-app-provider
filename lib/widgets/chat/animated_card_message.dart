import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class AnimatedCardMessage extends StatefulWidget {
  final bool isQuestion;
  final Function()? onAnimationComplete;

  const AnimatedCardMessage({
    Key? key,
    this.isQuestion = false,
    this.onAnimationComplete,
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
  bool applyBlur = false;
  double opacity = 0.0;

  late AnimationController imageController;

  @override
  void initState() {
    super.initState();

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

    // Begin animations sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() {
    // Initial fade sequence
    Future.delayed(Duration(milliseconds: 2100), () {
      if (mounted) {
        setState(() {
          _decreaseOpacity();
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isGlowVisible = false;
            });
          });
        });
      }
    });

    // Box visibility and completion animations
    Future.delayed(Duration(milliseconds: widget.isQuestion ? 2800 : 2400), () {
      setState(() {
        isBoxVisible = true;
        Future.delayed(Duration(milliseconds: 800), () {
          setState(() {
            iconOpacity = 1.0;
            repeatGlow = false;
            isQuesAnimVisible = false;
          });
          if (widget.onAnimationComplete != null) {
            widget.onAnimationComplete!();
          }
        });
      });
    });
  }

  void _decreaseOpacity() async {
    for (double i = 1.0; i >= 0.0; i -= 0.05) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          opacityLevel = i;
        });
      }
    }
  }

  @override
  void dispose() {
    imageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      : getResponsiveHeight(context, 0.3),
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
            if (isBoxVisible) ...[
              Lottie.asset(
                "assets/animations/Inner+Outerbox+Glow/Outerbox/Outerbox.json",
                width: getResponsiveWidth(context, 0.87),
                height: getResponsiveHeight(context, 0.33),
                fit: BoxFit.fill,
                repeat: false,
              ),
              Lottie.asset(
                "assets/animations/Inner+Outerbox+Glow/Outer Glow/Outerbox.json",
                width: getResponsiveWidth(context, 0.87),
                height: getResponsiveHeight(context, 0.33),
                fit: BoxFit.fill,
                repeat: repeatGlow,
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: getResponsivePadding(context, 12),
                    left: getResponsivePadding(context, 18),
                    right: getResponsivePadding(context, 12),
                  ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextAnimator(
                              "Here is a reference to the card",
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
                              maxLines: 8,
                            ),
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
                          ],
                        ),
                      ),
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
          borderRadius: BorderRadius.circular(getResponsiveWidth(context, 0.032)), // ~12 on 375 width
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            opacity: ((opacity - 0.3) <= 0.0) ? 0 : opacity - 0.3,
            child: Image.asset(
              'assets/images/login.jpg',
              width: getResponsiveWidth(context, 0.7),
              height: getResponsiveHeight(context, 0.2), // ~200px on 1000px height
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Lottie.asset(
            'assets/animations/gradient.json',
            fit: BoxFit.cover,
            repeat: false,
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.26,
              child: Image.asset(
                'assets/images/blur.jpeg',
                height: getResponsiveHeight(context, 0.07),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Positioned(
          bottom: getResponsiveHeight(context, 0.01), // ~10px on 1000px height
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
                  offset: Offset(0, imageController.value < 0.8 ? getResponsiveHeight(context, 0.02) : 0), // ~20px on 1000px height
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
