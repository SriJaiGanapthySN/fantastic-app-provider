import 'package:flutter/material.dart';

class VoiceRippleAnimation extends StatefulWidget {
  final bool isActive;
  final double size;
  final Color color;
  final int rippleCount;

  const VoiceRippleAnimation({
    Key? key,
    required this.isActive,
    this.size = 200,
    this.color = Colors.blue,
    this.rippleCount = 3,
  }) : super(key: key);

  @override
  State<VoiceRippleAnimation> createState() => _VoiceRippleAnimationState();
}

class _VoiceRippleAnimationState extends State<VoiceRippleAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.rippleCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted && widget.isActive) {
          _controllers[i].repeat();
        }
      });
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(VoiceRippleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom ripple effects
          ..._animations.asMap().entries.map((entry) {
            final index = entry.key;
            final animation = entry.value;

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final scale = animation.value;
                final opacity = 1.0 - animation.value;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size * (0.6 + (index * 0.2)),
                    height: widget.size * (0.6 + (index * 0.2)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(opacity * 0.8),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Center pulse
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.isActive ? 60 : 50,
            height: widget.isActive ? 60 : 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(widget.isActive ? 0.8 : 0.6),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.mic,
              color: Colors.white,
              size: widget.isActive ? 30 : 25,
            ),
          ),
        ],
      ),
    );
  }
}
