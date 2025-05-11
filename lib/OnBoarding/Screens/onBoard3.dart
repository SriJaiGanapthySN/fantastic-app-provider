import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../States/StateNotifiers.dart';
import '../Widgets/whiteBox.dart';
import 'onBoard4.dart';

class OnBoard3 extends ConsumerStatefulWidget {
  const OnBoard3({super.key});

  @override
  ConsumerState<OnBoard3> createState() => _OnBoard3State();
}

class _OnBoard3State extends ConsumerState<OnBoard3> {
  String? selectedText;
  bool fadeOut = false;

  void handleTap(String text) async {
    setState(() {
      selectedText = text;
      fadeOut = true;
    });

    await Future.delayed(const Duration(milliseconds: 300)); // Wait for fade

    ref.read(selectedSleepProvider.notifier).select(text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnBoard4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final options = [
      "7 hours or less",
      "7-9 hours",
      "9-12 hours",
      "12 hours or more",
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboardingImages/f63c5509baeec25e4e519a24bccd1b71_img_enchant_hypnosis_eat_for_your_health_big_image_opt.jpg',
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
                  "How much time do you usually get at night?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),

                // Build all white boxes
                for (var option in options) ...[
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
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
