import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/managers/animation_controller_manager.dart';

class AnimationNotifier extends StateNotifier<AnimationControllerManager?> {
  final TickerProvider tickerProvider;

  AnimationNotifier(this.tickerProvider) : super(null) {
    state = AnimationControllerManager(tickerProvider);
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

  AnimationController? get mindController => state?.mindController;
  AnimationController? get rippleController => state?.rippleController;

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final animationProvider = StateNotifierProvider.family<AnimationNotifier,
    AnimationControllerManager?, TickerProvider>((ref, tickerProvider) {
  return AnimationNotifier(tickerProvider);
});
