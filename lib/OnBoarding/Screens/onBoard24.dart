import 'package:flutter/material.dart';
import 'onBoard25.dart';

class OnBoard24 extends StatelessWidget {
  const OnBoard24({super.key});

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
            'assets/images/fabulous_onboarding_ios17.jpg', // Your background image
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
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(flex: 3,),
                Text(
                  'Track many more habits, and create healthy routines from within your Fabulous account.',
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
                        MaterialPageRoute(builder: (context) => Onboard25()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Make button background transparent
                      shadowColor: Colors.transparent,     // Remove shadow if you want clean look
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 1, 94, 195), Color.fromARGB(255, 2, 133, 193)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: height * 0.022,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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

