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
            left: screenHeight * 0.04,
            // Added right margin to fix overflow
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                    stops: const [0.1, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
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
      ],
    );
  }
}
