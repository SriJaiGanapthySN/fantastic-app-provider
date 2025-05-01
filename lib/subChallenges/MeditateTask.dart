import 'package:flutter/material.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  // Helper method to build the inactive progress indicators
  Widget _buildProgressIndicator(int number) {
    return Container(
      width: 36, // Diameter of the circle
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background for inactive
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: Colors.grey[600], // Darker grey text for inactive
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on the image for consistency
    const Color primaryGreen = Color(0xFF00695C); // Dark Teal variant
    const Color buttonGreen = Color(0xFF00BFA5); // Brighter Teal/Green for button

    return Scaffold(
      // Using the primary green for the entire background initially
      // The white part will be a Container stacked on top
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: primaryGreen, // Match background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Goal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        // Use Column to stack the green content area and the white bottom area
        children: [
          // --- Top Green Content Area ---
          Expanded( // Allows this section to take available space
            child: Container(
              width: double.infinity, // Ensure it fills width
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                children: [
                  // Meditation Icon
                  const Icon(
                    Icons.self_improvement, // Standard Flutter icon
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Meditate",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Description 1
                  const Text(
                    "Your challenge is to complete a new meditation session 7 times this week, starting with the 5 minute intro to meditation.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Slightly less opaque white
                      fontSize: 16.5, // Adjusted size
                      height: 1.4, // Line spacing
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Description 2
                  Text(
                    "Meditate has been added to your 7-Day Meditate Challenge. Mark it as complete to progress your goal!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85), // Even less opaque
                      fontSize: 14.5, // Slightly smaller
                      height: 1.4,
                    ),
                  ),
                  const Spacer(), // Pushes content towards center if space allows
                ],
              ),
            ),
          ),

          // --- Bottom White Area ---
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 32.0), // Padding inside white area
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content height
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Do it 7 times" Title
                const Text(
                  "Do it 7 times to succeed",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Progress Indicators Row
                // Displaying 7 indicators as implied by the text, styled as inactive
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute circles evenly
                  children: List.generate(7, (index) => _buildProgressIndicator(index + 1)),
                  // Note: On very narrow screens, 7 might overflow. Consider Wrap widget if needed.
                ),
                const SizedBox(height: 28),

                // Action Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonGreen, // Use the brighter green
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52), // Full width, specific height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement button action - mark as done for today
                    debugPrint("I have done this today! button pressed.");
                  },
                  child: const Text("I have done this today!"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}