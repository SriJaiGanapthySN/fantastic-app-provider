import 'package:flutter/material.dart';

class AnimationControllerManager {
  final TickerProvider vsync;
  late AnimationController mindController;
  late AnimationController rippleController;
  late AnimationController mindBoxController;
  late AnimationController boxAnimationController;
  late AnimationController glowAnimationController;
  late AnimationController mainController;

  bool isReversing = false;

  AnimationControllerManager(this.vsync) {
    _initializeControllers();
  }

  void _initializeControllers() {
    mindController = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: 5),
    )..addListener(_handleMindControllerUpdate);

    rippleController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 8),
    )..repeat();

    mindBoxController = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: 2),
    )..repeat();

    mainController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: vsync,
    )..forward();

    // Set up box and glow animation controllers
    int textDurationMs = 800;
    Duration textAnimationDuration = Duration(milliseconds: textDurationMs);

    boxAnimationController = AnimationController(
      vsync: vsync,
      duration: textAnimationDuration,
    )..forward();

    glowAnimationController = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: 3),
    )..forward();
  }

  void _handleMindControllerUpdate() {
    if (mindController.value > 0.99 && !isReversing) {
      isReversing = true;
      mindController.reverse();
    } else if (mindController.value < 0.13 && isReversing) {
      isReversing = false;
      mindController.forward();
    }
  }

  void startMindAnimation() {
    mindController.reset();
    mindController.forward();
  }

  void stopMindAnimation() {
    mindController.stop();
  }

  void resetRipple() {
    rippleController.reset();
    rippleController.forward();
  }

  void stopAllAnimations() {
    mindController.stop();
    rippleController.stop();
    mindBoxController.stop();
    boxAnimationController.stop();
    glowAnimationController.stop();
    mainController.stop();
  }

  void dispose() {
    // Stop all animations first to prevent ticker issues
    stopAllAnimations();

    // Then dispose the controllers
    mindController.dispose();
    rippleController.dispose();
    mindBoxController.dispose();
    boxAnimationController.dispose();
    glowAnimationController.dispose();
    mainController.dispose();
  }
}
