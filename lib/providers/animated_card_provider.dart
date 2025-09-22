import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A class to hold the arguments for our provider, ensuring it's immutable.
@immutable
class AnimatedCardProviderArgs {
  final String id;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  const AnimatedCardProviderArgs({
    required this.id,
    required this.shouldAnimate,
    this.onAnimationComplete,
  });

  // Override == and hashCode to ensure the provider family works correctly
  // when comparing complex objects.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimatedCardProviderArgs &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          shouldAnimate == other.shouldAnimate &&
          onAnimationComplete == other.onAnimationComplete;

  @override
  int get hashCode =>
      id.hashCode ^ shouldAnimate.hashCode ^ onAnimationComplete.hashCode;
}

// 1. Define the state for our animation
class AnimatedCardState {
  final bool isContentVisible;
  final bool showSparkle;

  const AnimatedCardState({
    this.isContentVisible = false,
    this.showSparkle = false,
  });

  AnimatedCardState copyWith({
    bool? isContentVisible,
    bool? showSparkle,
  }) {
    return AnimatedCardState(
      isContentVisible: isContentVisible ?? this.isContentVisible,
      showSparkle: showSparkle ?? this.showSparkle,
    );
  }
}

// 2. Create the StateNotifier
class AnimatedCardNotifier extends StateNotifier<AnimatedCardState> {
  final VoidCallback? onAnimationComplete;

  AnimatedCardNotifier({required bool shouldAnimate, this.onAnimationComplete})
      : super(const AnimatedCardState()) {
    if (shouldAnimate) {
      _startAnimations();
    } else {
      _showFinalState();
    }
  }

  void _startAnimations() async {
    // 1. Show sparkle animation
    await Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        state = state.copyWith(showSparkle: true);
      }
    });

    // 2. Hide sparkle and show content after a delay
    await Future.delayed(const Duration(milliseconds: 1200), () {
      // Sparkle duration
      if (mounted) {
        state = state.copyWith(showSparkle: false, isContentVisible: true);
        onAnimationComplete?.call();
      }
    });
  }

  void _showFinalState() {
    state = state.copyWith(isContentVisible: true, showSparkle: false);
    onAnimationComplete?.call();
  }
}

// 3. Create the StateNotifierProvider using the arguments class
final animatedCardProvider = StateNotifierProvider.autoDispose
    .family<AnimatedCardNotifier, AnimatedCardState, AnimatedCardProviderArgs>(
        (ref, args) {
  return AnimatedCardNotifier(
    shouldAnimate: args.shouldAnimate,
    onAnimationComplete: args.onAnimationComplete,
  );
});
