import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../States/StateNotifiers.dart';
import 'onBoard30.dart';

class OnBoard29 extends ConsumerStatefulWidget {
  const OnBoard29({super.key});

  @override
  ConsumerState<OnBoard29> createState() => _OnBoard29State();
}

class _OnBoard29State extends ConsumerState<OnBoard29> {
  late String displayText;
  double buttonSize = 100.0;
  double initialButtonSize = 100.0;
  double maxButtonSize = 200.0;
  Timer? growTimer;

  @override
  void initState() {
    super.initState();
    final personalDetails = ref.read(selectedSleepProvider.notifier).personalDetails;
    final name = personalDetails.isNotEmpty ? personalDetails.first : 'Name';
    displayText = "$name's contract";

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        displayText = "$name's Contract\n\n"
            "I, $name, will make the most of tomorrow. "
            "I will always remember that I will not live forever. "
            "Every fear and irritation that threatens to distract me "
            "will become fuel for building my best life one day at a time.";
      });
    });
  }

  void _startGrowing() {
    growTimer?.cancel();
    growTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (buttonSize < maxButtonSize) {
          buttonSize += 2;
        } else {
          timer.cancel();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OnBoard30()));
        }
      });
    });
  }

  void _stopGrowing() {
    growTimer?.cancel();
    setState(() {
      buttonSize = initialButtonSize;
    });
  }

  @override
  void dispose() {
    growTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personalDetails = ref.watch(selectedSleepProvider.notifier).personalDetails;
    final name = personalDetails.isNotEmpty ? personalDetails.first : 'Name';

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/onboardingImages/29422565604857cc3d9b651485bb53eb_img_hypnotic_lune_still_as_a_forest_lake_inner_step_opt.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blue Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Centered Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    displayText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTapDown: (_) => _startGrowing(),
                  onTapUp: (_) => _stopGrowing(),
                  onTapCancel: () => _stopGrowing(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(buttonSize / 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Hold',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

