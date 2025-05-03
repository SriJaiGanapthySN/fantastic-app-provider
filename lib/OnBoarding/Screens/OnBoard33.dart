import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../States/StateNotifiers.dart';
import 'onBoard35.dart';

class OnBoard33 extends ConsumerStatefulWidget {
  const OnBoard33({super.key});

  @override
  ConsumerState<OnBoard33> createState() => _OnBoard33State();
}
class _OnBoard33State extends ConsumerState<OnBoard33> {
  late String displayText;
  @override
  void initState() {
    super.initState();
    final personalDetails = ref.read(selectedSleepProvider.notifier).personalDetails;
    final name = personalDetails.isNotEmpty ? personalDetails.first : 'Name';
    displayText = "$name";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image and Color
          Container(
            decoration: BoxDecoration(
              color: Colors.purple, // Purple base color
              image: DecorationImage(
                image: AssetImage('assets/images/onboardingImages/8bc243b8878eebf35dac9034ad5ddf71_img_enchant_hypnosis_eat_for_your_health_inner_step_opt.jpg'), // Replace with your image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.purple.withOpacity(0.5), // Purple overlay
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${displayText}'s First Step",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(flex: 3),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet tellus vitae malesuada aliquet. Pellentesque dolor ipsum, blandit nec euismod ut, volutpat eu arcu. Lorem ipsum dolor sit amet, consectetur.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.1,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Onboard35(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade900, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
}
