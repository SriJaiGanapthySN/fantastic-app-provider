import 'package:fantastic_app_riverpod/subChallenges/SuperPower.dart';
import 'package:fantastic_app_riverpod/subChallenges/SuperPowerList.dart';
import 'package:fantastic_app_riverpod/subChallenges/testing.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter

class NameChallengeScreen extends StatefulWidget {
  final String imageUrl;// Expect the URL for the main image
  final String title;
  final String objectId;
  const NameChallengeScreen({super.key, required this.imageUrl, required this.title, required this.objectId});

  @override
  State<NameChallengeScreen> createState() => _NameChallengeScreenState();
}

class _NameChallengeScreenState extends State<NameChallengeScreen> {
  late TextEditingController _textController;
  final double _buttonContainerHeight = 95.0; // Define height for button area

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const Color scaffoldBgColor = Color(0xFFF8F5F1); // Store background color

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack( // Use Stack for layering image and button over content
        children: [
          // 1. Main Scrollable Content Area (takes full space initially)
          Positioned.fill(
            // Leave space at the bottom for the image fade AND the button container
            bottom: _buttonContainerHeight + (screenHeight * 0.1), // Adjust 0.1 as needed for image overlap
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Increased horizontal padding
              child: Column(
                // *** Center align the Column's content ***
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main Title (Centered)
                  const Text(
                    "Name your challenge routine",
                    textAlign: TextAlign.center, // Ensure text itself centers if wrapping
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle with Emoji (Centered)
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: "Personalize it to your liking to make it fun and inspiring! "),
                        TextSpan(text: "💃", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    textAlign: TextAlign.center, // Ensure text itself centers
                  ),
                  const SizedBox(height: 60), // More space

                  // --- Editable Challenge Name Section (Already Centered Internally) ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _textController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter the name of the challenge",
                          hintStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF999999),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        cursorColor: const Color(0xFF00796B),
                        maxLines: null,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFFE91E63),
                        size: 30,
                      ),
                    ],
                  ),
                  // --- End Editable Challenge Name Section ---
                  const SizedBox(height: 30), // Ensure spacing at the end of scroll
                ],
              ),
            ),
          ),

          // 2. Fading Background Image (positioned above the button container)
          Positioned(
            bottom: _buttonContainerHeight - 10, // Start slightly above the button container edge
            left: 0,
            right: 0,
            height: screenHeight * 0.4, // Adjust height as needed
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                // Linear gradient from transparent top to opaque bottom (relative to image bounds)
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black], // Fade *in* the image from top
                  stops: [0.0, 0.6], // Adjust stops: 0.0=fully transparent, 0.6=fully opaque
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn, // Apply transparency mask to the image
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover, // Cover the assigned space
                alignment: Alignment.bottomCenter, // Align image bottom within its bounds
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // Handle error
              ),
            ),
          ),


          // 3. Bottom Button Container (White, Rounded Top)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _buttonContainerHeight, // Give it a defined height
              padding: const EdgeInsets.fromLTRB(24.0, 18.0, 24.0, 25.0), // Adjust padding (more bottom for safe area)
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
                boxShadow: [ // Optional: Add subtle shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10.0,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B), // Teal
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // Full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    // Padding is handled by the container now, ensure button fills height
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    )
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SuperPowerScreen(imageUrl: widget.imageUrl,objectId: widget.objectId,title: widget.title,)));
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => SkillLevelDetailScreen(skillTrackId: widget.objectId,)));
                  // Add navigation/action
                },
                child: const Text("CONTINUE"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}