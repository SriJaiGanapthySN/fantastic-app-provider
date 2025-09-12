import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeafLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const LeafLoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = Colors.green,
  }) : super(key: key);

  @override
  State<LeafLoadingIndicator> createState() => _LeafLoadingIndicatorState();
}

class _LeafLoadingIndicatorState extends State<LeafLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SvgPicture.asset(
              'assets/icons/leaf.svg',
              height: widget.size,
              width: widget.size,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
