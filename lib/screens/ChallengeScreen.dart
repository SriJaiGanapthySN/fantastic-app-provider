import 'package:fantastic_app_riverpod/widgets/challanges/ChallengesButton.dart';
// Assuming DiscoverButtons might be needed elsewhere, keeping the import
// import 'package:fantastic_app_riverpod/widgets/discover/discoverbuttons.dart';
import 'package:flutter/material.dart';
// Assuming Riverpod might be used elsewhere or in ChallengeButton, keeping the import
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
// Assuming ChallengesService might be needed elsewhere, keeping the import
// import '../services/challenges_service.dart';
import '../subChallenges/SubChallengeScreen.dart';
import '../widgets/challanges/cardLayout.dart'; // Ensure this path is correct

// Make sure ChallengeScreen exists if you intend to navigate TO it again.
// If this IS the screen you navigate TO, ensure the naming is consistent.
// For clarity, let's assume the screen you navigate TO might have a different name
// or purpose, but for this example, we'll use the same name as requested.

class ChallengeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cardData;
  const ChallengeScreen({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    // 👇 Print cardData when the screen builds
    debugPrint('CardData in ChallengeScreen build: $cardData');

    // --- Define the handleButtonPress method ---
    void handleButtonPress(int index) {
      debugPrint('Button pressed with index: $index'); // For debugging
      if (index == 1) {
        // Navigate to ChallengeScreen if index is 1
        Navigator.push(
          context,
          MaterialPageRoute(
            // Pass the current cardData to the new screen instance
            builder: (context) => Sub_Challenge_Screen(cardData: cardData),
          ),
        );
      } else {
        // Do nothing if index is 0 (or any other value)
        debugPrint('Index is $index, no navigation action taken.');
      }
    }
    // --- End of handleButtonPress method definition ---

    return Scaffold(
      backgroundColor: Colors.black, // keep black
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgdiscover.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Background Lottie animation (commented out as in original)
          // Positioned.fill(
          //   child: Container(
          //     color: Colors.black.withOpacity(0.5),
          //   ),
          // ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            width: MediaQuery.of(context).size.width * 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.3, 0.7, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.white,
                        Colors.transparent,
                        Colors.transparent, // Bottom edge fades out
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0.0, 0.1, 0.9, 1.0],
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.transparent, // Right edge fades out
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      "assets/images/image (2).png",
                      height: 480,
                      width: 480,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Cross button at top
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  // Added padding for better touch area
                  padding: const EdgeInsets.only(
                      top: 40.0, right: 16.0), // Adjust padding as needed
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black87, size: 28),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              // Semi-transparent black overlay (commented out as in original)
              // Main Content (Cross button + Cards)
              // The card layout (moved inside the second Column)
            ],
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Lottie.asset(
          //     'assets/animations/challenge.json', // your lottie file path
          //     fit: BoxFit.cover,
          //     repeat: true,
          //   ),
          // ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              // Use the defined handleButtonPress and set default index to 1
              ChallengeButton(
                handleButtonPress: handleButtonPress, // Pass the method here
                selectedButtonIndex: 0, // Default index is 1
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Expanded(child: CardLayout(cardData: cardData)),
            ],
          ),
        ],
      ),
    );
  }
}
