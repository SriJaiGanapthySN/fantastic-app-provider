import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'onBoard7.dart';
import '../States/StateNotifiers.dart';
import '../Widgets/whiteBox.dart';

class OnBoard6 extends ConsumerStatefulWidget {
  const OnBoard6({super.key});

  @override
  ConsumerState<OnBoard6> createState() => _OnBoard6State();
}

class _OnBoard6State extends ConsumerState<OnBoard6> {
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
      MaterialPageRoute(builder: (context) => const OnBoard7()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final options = [
      "High-energised throughout the day",
      "Medium-I have bursts of energy",
      "Low- My energy fades throughout the day"
    ];

    return Scaffold(
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
              children: [
                const Spacer(flex: 1),
                Text(
                  "Understood! Throughout your day, how are your energy levels?",
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
