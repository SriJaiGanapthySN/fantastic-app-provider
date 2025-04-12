import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimationManager {
  final AnimationController rippleController;
  final AnimationController mindController;
  VoidCallback? onAnimationStart;

  AnimationManager({
    required this.rippleController,
    required this.mindController,
    this.onAnimationStart,
  });

  void dispose() {
    rippleController.dispose();
    mindController.dispose();
  }

  void startMindAnimation() {
    if (!mindController.isAnimating) {
      // Ensure the animation starts immediately and loops properly
      mindController.reset();
      mindController.repeat(reverse: true);

      // Notify when animation starts (for scrolling)
      if (onAnimationStart != null) {
        onAnimationStart!();
      }
    }
  }

  void stopMindAnimation() {
    if (mindController.isAnimating) {
      mindController.stop();
    }
  }

  void resetRipple() {
    rippleController.reset();
    rippleController.forward();
  }
}

class AnimationNotifier extends StateNotifier<AnimationManager?> {
  final TickerProvider tickerProvider;
  bool _disposed = false;

  AnimationNotifier(this.tickerProvider) : super(null) {
    _initialize();
  }

  void _initialize() {
    final rippleController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 1000),
    );

    final mindController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 2000),
    );

    // Start the mind animation by default
    mindController.repeat(reverse: true);

    state = AnimationManager(
      rippleController: rippleController,
      mindController: mindController,
    );
  }

  @override
  void dispose() {
    if (!_disposed) {
      state?.dispose();
      _disposed = true;
    }
    super.dispose();
  }

  void startMindAnimation() {
    state?.startMindAnimation();
  }

  void stopMindAnimation() {
    state?.stopMindAnimation();
  }

  void resetRipple() {
    state?.resetRipple();
  }

  void setOnAnimationStart(VoidCallback callback) {
    if (state != null) {
      state = AnimationManager(
        rippleController: state!.rippleController,
        mindController: state!.mindController,
        onAnimationStart: callback,
      );
    }
  }
}

final animationProvider = StateNotifierProvider.family<AnimationNotifier,
    AnimationManager?, TickerProvider>(
  (ref, tickerProvider) {
    final notifier = AnimationNotifier(tickerProvider);
    ref.onDispose(() {
      notifier.dispose();
    });
    return notifier;
  },
);
