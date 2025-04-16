import 'package:flutter/material.dart';

import 'onBoard3.dart';

class OnBoard2 extends StatelessWidget {
  const OnBoard2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboardingImages/f682d348d09fd5f7994becc03d8870d4_img_enchant_affirmation_build_confidence_inner_step.jpg', // Your background image
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3), // optional dark overlay
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                Text(
                  'Create the perfect\nroutine for you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(flex: 3,),
                Text(
                  'Using psychology and behavioural science\nyou will create healthy habits that stick',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.02,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: height * 0.03),
                SizedBox(
                  width: double.infinity,
                  height: height * 0.07,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => OnBoard3()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Let's Get Started",
                      style: TextStyle(
                        fontSize: height * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
