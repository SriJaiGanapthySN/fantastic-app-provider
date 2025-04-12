import 'package:fantastic_app_riverpod/widgets/discover/discoverbuttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../services/challenges_service.dart';
import '../widgets/challanges/cardLayout.dart';

class ChallengeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cardData;
  const ChallengeScreen({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    // 👇 Print cardData when the screen builds
    debugPrint('CardData in ChallengeScreen build: $cardData');

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
          // Background Lottie animation
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
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),

              // Semi-transparent black overlay to make cards & icons pop

              // Main Content (Cross button + Cards)

              // The card layout
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/animations/challenge.json', // your lottie file path
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Column(
            children: [
              Discoverbuttons(handleButtonPress:(){} , selectedButtonIndex: 0),
              SizedBox(height: MediaQuery.of(context).size.height * 0.13),
              Expanded(child: CardLayout(cardData: cardData)),
            ],
          ),
        ],
      ),
    );
  }
}
