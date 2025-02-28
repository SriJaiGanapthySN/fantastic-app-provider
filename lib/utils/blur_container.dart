import 'package:flutter/material.dart';
import 'dart:ui';

class BlurContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Border? border;
  final double? width;
  final double? height;
  final bool enableGlow;
  final Color? glowColor;
  final double glowSpread;
  final double glowIntensity;

  const BlurContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius,
    this.padding,
    this.color,
    this.border,
    this.width,
    this.height,
    this.enableGlow = false,
    this.glowColor,
    this.glowSpread = 44,
    this.glowIntensity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: enableGlow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              boxShadow: [
                BoxShadow(
                  color: (glowColor ?? color ?? Colors.white)
                      .withValues(alpha: glowIntensity),
                  blurRadius: glowSpread,
                  spreadRadius: 0,
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              border: border,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
