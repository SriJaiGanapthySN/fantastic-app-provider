import 'dart:ui';

import 'package:fantastic_app_riverpod/widgets/discover/custombuttondiscover.dart';
import 'package:flutter/material.dart';

class Discoverbuttons extends StatelessWidget {
  const Discoverbuttons(
      {super.key,
      required this.handleButtonPress,
      required this.selectedButtonIndex});

  final Function handleButtonPress;
  final int selectedButtonIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: screenWidth * 0.5),
        Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.12,
            left: screenHeight * 0.05,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Colors.white],
                stops: const [
                  0.0,
                  0.15
                ], // Adjust stop values to control mask width
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButtonDiscover(
                          routineName: "Journeys",
                          handleButtonPress: handleButtonPress,
                          a: 0,
                          selectedButtonIndex: selectedButtonIndex),
                      CustomButtonDiscover(
                          routineName: "Coaching Series",
                          handleButtonPress: handleButtonPress,
                          a: 1,
                          selectedButtonIndex: selectedButtonIndex),
                      CustomButtonDiscover(
                          routineName: "Guided Activities",
                          handleButtonPress: handleButtonPress,
                          a: 2,
                          selectedButtonIndex: selectedButtonIndex),
                      CustomButtonDiscover(
                          routineName: "Challenges",
                          handleButtonPress: handleButtonPress,
                          a: 3,
                          selectedButtonIndex: selectedButtonIndex)
                    ],
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
