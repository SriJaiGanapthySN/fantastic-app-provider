import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onBoard8.dart';
import '../States/StateNotifiers.dart';
import '../Widgets/whiteBox.dart';

class OnBoard7 extends ConsumerStatefulWidget {
  const OnBoard7({super.key});

  @override
  ConsumerState<OnBoard7> createState() => _OnBoard7State();
}

class _OnBoard7State extends ConsumerState<OnBoard7> {
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
      MaterialPageRoute(builder: (context) => const OnBoard8()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final options = [
      "Completely- I feel fit and healthy",
      "Somewhat- I would like to see some improvement",
      "Not at all- I'd like to see a major change"
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboardingImages/ce972552ecf11c1fdf4380331d2b3930_img_enchant_hypnosis_overcoming_fear_inner_step_opt.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                Text(
                  "How satisfied are you with your current fitness level?",
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
