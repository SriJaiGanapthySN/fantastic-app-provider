import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WaveTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isAnimating;
  final Duration duration;

  const WaveTextAnimation({
    Key? key,
    required this.text,
    this.style,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<WaveTextAnimation> createState() => _WaveTextAnimationState();
}

class _WaveTextAnimationState extends State<WaveTextAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<AnimationController> _characterControllers = [];
  final List<Animation<double>> _characterAnimations = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _setupCharacterAnimations();

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  void _setupCharacterAnimations() {
    // Dispose existing controllers
    for (final controller in _characterControllers) {
      controller.dispose();
    }
    _characterControllers.clear();
    _characterAnimations.clear();

    if (widget.text.isEmpty) return;

    final characters = widget.text.split('');
    for (int i = 0; i < characters.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));

      _characterControllers.add(controller);
      _characterAnimations.add(animation);
    }
  }

  void _startAnimation() {
    _controller.repeat(reverse: true);

    // Animate characters in sequence
    for (int i = 0; i < _characterControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isAnimating) {
          _characterControllers[i].forward().then((_) {
            if (mounted) {
              _characterControllers[i].reverse();
            }
          });
        }
      });
    }
  }

  void _stopAnimation() {
    _controller.stop();
    _controller.reset();
    for (final controller in _characterControllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(WaveTextAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _setupCharacterAnimations();
    }

    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _characterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final characters = widget.text.split('');
    final defaultStyle = GoogleFonts.roboto(
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        fontSize: 20,
      ),
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.white,
                Colors.white,
                Colors.white.withOpacity(0.6),
              ],
              stops: [
                0.0,
                _animation.value * 0.8,
                _animation.value * 0.8 + 0.1,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: characters.asMap().entries.map((entry) {
              final index = entry.key;
              final character = entry.value;

              if (character == ' ') {
                return const SizedBox(width: 8);
              }

              if (index >= _characterAnimations.length) {
                return Text(
                  character,
                  style: widget.style ?? defaultStyle,
                );
              }

              return AnimatedBuilder(
                animation: _characterAnimations[index],
                builder: (context, child) {
                  final scale = 1.0 + (_characterAnimations[index].value * 0.3);
                  final translateY = -_characterAnimations[index].value * 10;

                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Text(
                        character,
                        style: widget.style ?? defaultStyle,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
