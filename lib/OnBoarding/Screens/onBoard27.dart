import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../States/StateNotifiers.dart';
import '../Widgets/whiteBox.dart';

import 'onBoard28.dart';

class OnBoard27 extends ConsumerStatefulWidget {
  const OnBoard27({super.key});

  @override
  ConsumerState<OnBoard27> createState() => _OnBoard27State();
}

class _OnBoard27State extends ConsumerState<OnBoard27> {
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
      MaterialPageRoute(builder: (context) => const OnBoard28()), // Replace with your next screen
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final options = [
      "Woman",
      "Man",
      "Non-Binary"
    ];

    return Scaffold(
      backgroundColor: CupertinoColors.activeBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboardingImages/4f7e01562ba3e5419ac3e151f21e16e8_img_enchant_hypnosis_making_healthy_choices_big_image_opt.jpg',
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
                  "How do you identify?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  "At times, we'll provide gender-specific recommendations",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.02,
                  ),
                ),
                SizedBox(height: height * 0.02),

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
