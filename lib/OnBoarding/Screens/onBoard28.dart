import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../States/StateNotifiers.dart';
import '../Widgets/whiteBox.dart';

import 'onBoard29.dart';

class OnBoard28 extends ConsumerStatefulWidget {
  const OnBoard28({super.key});

  @override
  ConsumerState<OnBoard28> createState() => _OnBoard28State();
}

class _OnBoard28State extends ConsumerState<OnBoard28> {
  String? selectedText;
  bool fadeOut = false;

  void handleTap(String text) async {
    setState(() {
      selectedText = text;
      fadeOut = true;
    });

    // Wait for fade-out animation to complete before navigating
    await Future.delayed(const Duration(milliseconds: 600));

    ref.read(selectedSleepProvider.notifier).addPersonalDetails(text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnBoard29()), // Replace with your next screen
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final options = [
      "7:00AM",
      "8:00AM",
      "9:00AM",
      "Other time"
    ];

    return Scaffold(
      backgroundColor: CupertinoColors.activeBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/fabulous_onboarding_ios17.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Text(
                  "When do you wake up generally?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),

                // WhiteBoxes with tap handlers
                for (var option in options) ...[
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: (selectedText == null || selectedText == option)
                        ? (selectedText == option && fadeOut ? 0 : 1)
                        : 1,
                    child: GestureDetector(
                      onTap: () => handleTap(option),
                      child: WhiteBox(text: option),
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                ],

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
