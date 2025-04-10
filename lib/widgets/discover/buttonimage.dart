import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Buttonimage extends StatelessWidget {
  const Buttonimage({super.key, required this.currentImage});
  final String currentImage;

  @override
  Widget build(BuildContext context) {
    return // Background Image first (bottom layer)
        Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.1,
          ),
          width: MediaQuery.of(context).size.width * 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.transparent,
                      Colors.transparent, // Bottom edge fades out
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.1, 0.9, 1.0],
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.transparent, // Right edge fades out
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    height: 480,
                    width: 480,
                    currentImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
