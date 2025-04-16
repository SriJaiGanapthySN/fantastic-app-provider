import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../States/StateNotifiers.dart';
import '../Widgets/whiteBox.dart';

import 'onBoard18.dart';

class OnBoard17 extends ConsumerStatefulWidget {
  const OnBoard17({super.key});

  @override
  ConsumerState<OnBoard17> createState() => _OnBoard17State();
}

class _OnBoard17State extends ConsumerState<OnBoard17> {
  String? selectedText;
  bool fadeOut = false;

  void handleTap(String text) async {
    setState(() {
      selectedText = text;
      fadeOut = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    ref.read(selectedSleepProvider.notifier).select(text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnBoard18()), // Replace with your next screen
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final options = ["Yes", "No"];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboardingImages/743d5be667ca0bdfd1fb00b648347781_img_enchant_affirmation_elements_of_happiness_inner_step_opt.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                Text(
                  "Did you take vitamins or supplements today?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.bold,
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
