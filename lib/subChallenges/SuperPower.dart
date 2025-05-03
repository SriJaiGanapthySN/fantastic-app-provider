import 'package:fantastic_app_riverpod/subChallenges/MediatatingPage.dart';
import 'package:fantastic_app_riverpod/subChallenges/SuperPowerList.dart';
import 'package:flutter/material.dart';
import '../OnBoarding/Widgets/imageCard1.dart';

class SuperPowerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String objectId;
  const SuperPowerScreen({super.key, required this.imageUrl, required this.title, required this.objectId});

  @override
  _SuperPowerScreenState createState() => _SuperPowerScreenState();
}

class _SuperPowerScreenState extends State<SuperPowerScreen> {
  final List<Superpowerlist> itemList = habitList; // your habit items
  final Set<String> selectedItems = {}; // local selection tracking

  void toggleSelection(String text) {
    setState(() {
      if (selectedItems.contains(text)) {
        selectedItems.remove(text);
      } else {
        selectedItems.add(text);
      }
    });
  }

  void _showGratitudeChallengeDialog(BuildContext context) {
    // Define colors based on the image
    const Color dialogBackgroundColor = Color(0xFF004D40); // Dark Teal Green
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70; // Slightly dimmer white for description
    const Color closeButtonColor = Colors.white70;
    const Color nextButtonColor = Color(0xFF81C784); // Light Green

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make default background transparent
          insetPadding: const EdgeInsets.all(20.0), // Padding around the dialog
          child: ClipRRect( // Apply rounded corners to the content
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              color: dialogBackgroundColor, // Apply the main background color
              child: Stack( // Use Stack for the close button positioning
                children: [
                  // Main Content Column
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Make column height fit content
                      crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
                      children: [
                        const SizedBox(height: 30), // Space for close button area + top padding

                        // --- Gem Icon ---
                        Image.asset(
                          'assets/images/gratitude_gem.png', // <<< REPLACE WITH YOUR ASSET PATH
                          height: 100, // Adjust size as needed
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.diamond_outlined, // Fallback icon
                            size: 100,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 25.0),

                        // --- Title Text ---
                        const Text(
                          "Gratitude\nChallenge", // Use newline for line break
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.3, // Line height
                          ),
                        ),
                        const SizedBox(height: 15.0),

                        // --- Description Text ---
                        const Text(
                          "Express gratitude towards a friend and keep you on track.\nHeard of the saying, \"Standing on the shoulder of giants\"? We get more help than we think we are.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                            height: 1.5, // Line height
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        // --- Circular Next Button ---
                        FloatingActionButton(
                          onPressed: () {
                            _showExpressGratitudeDialog(context); // Close the dialog
                            // Potentially navigate or trigger next step
                          },
                          backgroundColor: nextButtonColor,
                          foregroundColor: Colors.white,
                          elevation: 2.0,
                          child: const Icon(Icons.arrow_forward),
                        ),
                        const SizedBox(height: 10.0), // Bottom padding
                      ],
                    ),
                  ),

                  // --- Close Button ---
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: closeButtonColor,
                      iconSize: 28,
                      tooltip: 'Close', // Accessibility
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExpressGratitudeDialog(BuildContext context) {
    // Define colors based on the image
    const Color dialogBackgroundColor = Colors.white;
    const Color primaryTextColor = Color(0xFF333333); // Dark text
    const Color secondaryTextColor = Color(0xFF555555); // Slightly lighter dark text
    const Color primaryButtonColor = Color(0xFF4CAF50); // Green button
    const Color secondaryButtonTextColor = Color(0xFF757575); // Grey text for second option

    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing by tapping outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder( // Apply rounded corners
            borderRadius: BorderRadius.circular(16.0),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0), // Dialog padding
          child: Padding( // Padding inside the dialog shape
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content height
              crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
              children: [
                // --- Title Text ---
                const Text(
                  "How to express gratitude",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 22, // Adjust size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),

                // --- Description Text ---
                const Text(
                  "Have you ever stopped to think how others have helped us?\n\nNot only does showing gratitude towards someone help you achieve your goals, it also builds long lasting relationships. Think of someone who has been nice to you, even in the smallest way, and let them know. This will help you achieve your goal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 15.5, // Adjust size as needed
                    height: 1.4, // Line spacing
                  ),
                ),
                const SizedBox(height: 24.0),

                // --- Illustration ---
                Image.asset(
                  'assets/images/family.png', // <<< REPLACE WITH YOUR ASSET PATH
                  height: 100, // Adjust size as needed
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.people_alt_outlined, // Fallback icon
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 28.0),

                // --- Primary Action Button ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48), // Full width, fixed height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 14, // Adjust size
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                    Navigator.of(dialogContext).pop(); // Close the dialog
                    // Potentially navigate or trigger next step
                  },
                  child: const Text("I WANT TO THANK SOMEONE!"),
                ),
                const SizedBox(height: 12.0),

                // --- Secondary Action Button ---
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    // foregroundColor: secondaryButtonTextColor, // Set color directly in text style
                  ),
                  onPressed: () {
                    // TODO: Implement action for NOT wanting to show gratitude
                    debugPrint("I don't want to show gratitude tapped!");
                    Navigator.of(dialogContext).pop(); // Close the dialog
                    Navigator.of(dialogContext).pop(); // Close the dialog

                  },
                  child: const Text(
                    "I DON'T WANT TO SHOW\nGRATITUDE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryButtonTextColor,
                      fontSize: 13, // Adjust size
                      fontWeight: FontWeight.w500, // Medium weight
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 43, 42, 88),
      body: Column(
        children: [
          // Top Section
          SizedBox(height: 25,),
          Align(
            alignment: Alignment.topLeft,
            child: Padding( // Added padding for better touch area
              padding: const EdgeInsets.only(top: 40.0, right: 16.0), // Adjust padding as needed
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pick Your Super Powers",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Last Step! increase your chances of success.\nWe suggest Picking 3 super powers. It is not required, but highly recommended if you're serious about achieving your goals.",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                  ),
                ),
              ],
            ),
          ),

          // Cards Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: EdgeInsets.only(bottom: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final item = itemList[index];
                  final isSelected = selectedItems.contains(item.text);

                  return GestureDetector(
                    onTap: () => {toggleSelection(item.text),_showGratitudeChallengeDialog(context)},
                    child: ImageCard1(
                      imageAdd: item.imageAdd,
                      text: item.text,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
          ),

          // Continue Button (only shown if any item selected)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 61, 60, 124),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> MeditationActionScreen(imageUrl: widget.imageUrl,objectId:widget.objectId,)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Continue", style: TextStyle(color: Colors.black)),
                    SizedBox(width: 8.0),
                    Icon(Icons.arrow_forward, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
