import 'package:flutter/material.dart';

import 'TimePage.dart';
// Removed unused import: import 'package:flutter/widgets.dart'; // Material already includes this

// --- Hex to Color Function (Keep as is) ---
Color hexToColor(String hexString, {String alpha = 'FF', Color defaultColor = Colors.white}) {
  hexString = hexString.toUpperCase().replaceAll("#", "");
  if (hexString.length == 6) {
    hexString = alpha + hexString;
  }
  if (hexString.length == 8) {
    try {
      return Color(int.parse("0x$hexString"));
    } catch (e) {
      // Use debugPrint instead of print for Flutter apps
      debugPrint("Error parsing hex color '$hexString': $e");
      return defaultColor;
    }
  }
  debugPrint("Invalid hex color format: '$hexString'");
  return defaultColor;
}
// --- End Hex to Color ---

class ChallengeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> challengeData;

  const ChallengeDetailScreen({
    required this.challengeData,
    super.key,
  });

  // --- Helper function to show the dialog ---
  void _showWhyDialog(BuildContext context) {
    // Define the teal color used in the dialog (adjust if needed)
    const Color dialogPrimaryColor = Color(0xFF009688); // A standard Teal
    const Color dialogTextColor = Color(0xFF616161); // Dark Grey for body text

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use a different context name
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0), // Adjust padding
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          actionsPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 20.0), // Adjust padding
          title: const Text(
            "Why am I doing this?",
            style: TextStyle(
              color: dialogPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: const SingleChildScrollView( // In case text is long
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A meditation routine makes you feel amazing.",
                  style: TextStyle(fontSize: 15.5, color: dialogTextColor, height: 1.4),
                ),
                SizedBox(height: 15.0), // Space between paragraphs
                Text(
                  "Studies show it has the same effect on your body and mind as a vacation, boosting your immune system and mood at the same time.",
                  style: TextStyle(fontSize: 15.5, color: dialogTextColor, height: 1.4),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Center the action button
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min, // Prevent Row from expanding
                children: [
                  Icon(Icons.thumb_up_alt_outlined, color: dialogPrimaryColor, size: 20), // Thumbs up icon
                  SizedBox(width: 8.0), // Space between icon and text
                  Text(
                    "OK, GOT IT",
                    style: TextStyle(
                      color: dialogPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  // --- End Helper function ---

  void _showDownloadDialog(BuildContext context) {
    // Define the pink color used in the dialog
    const Color dialogHeaderColor = Color(0xFFE91E63); // Material Pink
    const Color dialogTitleColor = Color(0xFFD81B60); // Darker Pink for Title/Button
    const Color dialogTextColor = Color(0xFF424242); // Dark Grey for body text

    showDialog(
      context: context,
      // barrierDismissible: false, // Optional: Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Use Dialog for more control over padding and shape than AlertDialog
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Match previous dialog
          ),
          elevation: 0, // Optional: remove shadow if needed
          backgroundColor: Colors.transparent, // Make dialog background transparent
          child: ClipRRect( // Clip content to rounded shape
            borderRadius: BorderRadius.circular(16.0),
            child: Container( // Use container to manage structure
              color: Colors.white, // White background for the main content area
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content height
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [
                  // --- Header Section (Pink Background + Image) ---
                  Container(
                    color: dialogHeaderColor, // Pink background
                    padding: const EdgeInsets.symmetric(vertical: 25.0), // Padding above/below image
                    child: Center(
                      // Placeholder for the cloud/map image
                      // Replace with your actual Image.asset widget when available
                      child: Image.asset(
                        'assets/images/download_placeholder.png', // <<<--- REPLACE WITH YOUR IMAGE PATH
                        height: 80, // Adjust height as needed
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cloud_download_outlined, // Fallback Icon
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // --- Content Section (White Background) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0), // Padding for text and button
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                      children: [
                        const Text(
                          "Almost there!",
                          style: TextStyle(
                            color: dialogTitleColor, // Use the pinkish color
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        const Text(
                          "Looks like we need to download this content before you begin your next adventure. We promise it'll be quick!",
                          style: TextStyle(
                            fontSize: 15.5,
                            color: dialogTextColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 25.0), // Space before button

                        // --- Download Button ---
                        Align( // Align button to the right
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            ),
                            child: const Text(
                              "DOWNLOAD NOW",
                              style: TextStyle(
                                color: dialogTitleColor, // Use the pinkish color
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                            onPressed: () {
                              _showStopChallengeDialog(context);
                            },
                          ),
                        ),
                      ],
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
  // --- End "Download" Dialog Helper ---

  void _showStopChallengeDialog(BuildContext context) {
    // Define the colors used in the dialog
    const Color dialogTitleColor = Color(0xFF26A69A); // Tealish color for title/main button
    const Color dialogTextColor = Color(0xFF424242); // Dark Grey for body text
    const Color secondaryButtonColor = Color(0xFF757575);
    final String imageUrl = challengeData['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              color: Colors.white, // White background for the content area
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content height
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header Section (Image) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0), // Adjust padding as needed
                    child: Center(
                      // Placeholder for the journey map image
                      // Replace with your actual Image.asset widget
                      child: Image.asset(
                        'assets/images/journey_map_placeholder.png', // <<<--- REPLACE WITH YOUR IMAGE PATH
                        height: 80, // Adjust height as needed
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.map_outlined, // Fallback Icon
                          size: 80,
                          color: Colors.grey, // Placeholder color
                        ),
                      ),
                    ),
                  ),

                  // --- Content Section (White Background) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 24.0), // Adjust top padding
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end, // Align text left
                      children: [
                        const Text(
                          "Ready to stop your challenge?",
                          style: TextStyle(
                            color: dialogTitleColor, // Use the tealish color
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        const Text(
                          "If you join a new challenge or journey, your current challenge will be reset. You can restart your current challenge from the beginning at any time.",
                          style: TextStyle(
                            fontSize: 15.5,
                            color: dialogTextColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 25.0), // Space before buttons

                        // --- Action Buttons ---
                        // Use a Column aligned to the end for stacked right-aligned buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjust padding
                                // Add minimum size to ensure tap target area if needed
                                // minimumSize: Size(88, 36),
                              ),
                              child: const Text(
                                "STOP CHALLENGE",
                                style: TextStyle(
                                  color: dialogTitleColor, // Tealish color
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengeTimeScreen(imageUrl: imageUrl,)));
                              },
                            ),
                            const SizedBox(height: 8.0), // Space between buttons
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjust padding
                              ),
                              child: const Text(
                                "DON'T SWITCH",
                                style: TextStyle(
                                  color: secondaryButtonColor, // Grey color
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () {
                                // Just close the dialog
                                debugPrint("Don't Switch tapped!");
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
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


  @override
  Widget build(BuildContext context) {
    final String title = challengeData['title'] ?? 'Challenge Detail';
    // Extract the 'why' description - provide a default if missing
    final String whyDescription = challengeData['whyDescription'] ??
        "Taking on this challenge helps build positive habits and improve well-being."; // Default Text
    final String description = challengeData['chapterDescription'] ?? 'No description available.';
    final String imageUrl = challengeData['imageUrl'] ?? '';
    final String goalSubtitle = challengeData['subtitle'] ?? 'Complete the challenge.';
    final String hexBgColor = challengeData['color'] ?? '#FFDD62';
    final String hexPrimaryColor = challengeData['ctaColor'] ?? '#1B6423';

    final Color topBackgroundColor = hexToColor(hexBgColor, defaultColor: const Color(0xFFFFDD62));
    final Color primaryActionColor = hexToColor(hexPrimaryColor, defaultColor: const Color(0xFF1B6423));
    final Color secondaryButtonBg = hexToColor('#EEF1E4', defaultColor: Colors.grey[100]!);
    final Color bodyTextColor = hexToColor('#4A4A4A', defaultColor: Colors.grey[800]!);
    final Color titleTextColor = hexToColor('#333333', defaultColor: Colors.black87);
    final Color secondaryIconColor = Colors.grey[600]!;

    final bool hasValidImageUrl = imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Scaffold(
      backgroundColor: topBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Section: Tag and Close Button ---
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 15.0),
              child: SizedBox(
                height: 40,
                child: Stack(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomPaint(
                      painter: _TagPainter(color: primaryActionColor),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                        child: Text(
                          "Fabulous Challenge",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.close, color: secondaryIconColor, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // --- Title and Description ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: titleTextColor, height: 1.3)),
                  const SizedBox(height: 12.0),
                  Text(description, style: TextStyle(fontSize: 16, color: bodyTextColor, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            // --- Image (Conditional Display) ---
            if(hasValidImageUrl) // Use if statement for cleaner conditional rendering
              Padding(
                padding: const EdgeInsets.only(top: 10.0), // Add some space if image is present
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Adjust height as needed
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryActionColor.withOpacity(0.7)),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[500], size: 50)),
                  ),
                ),
              ),

            // Use Spacer to push the bottom content down



            // --- Fixed White Bottom Container ---
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0), // Adjust bottom padding if needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Goal Section ---
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, color: primaryActionColor, size: 22), // Changed to outlined flag
                      const SizedBox(width: 8.0),
                      Text("Goal", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryActionColor)),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    goalSubtitle,
                    style: TextStyle(fontSize: 16, color: bodyTextColor.withOpacity(0.9), height: 1.4),
                  ),
                  const SizedBox(height: 30.0),

                  // --- WHY Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryButtonBg,
                      foregroundColor: primaryActionColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 12), // Ensure consistent padding
                    ),
                    // Call the dialog function on press
                    onPressed: () => _showWhyDialog(context), // Pass the build context
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 20, color: primaryActionColor),
                        const SizedBox(width: 10),
                        Text(
                          "WHY AM I DOING THIS?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryActionColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),

                  // --- Begin Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryActionColor,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 12), // Ensure consistent padding
                    ),
                    onPressed: () => _showDownloadDialog(context), // Use debugPrint
                    child: const Text("BEGIN THE CHALLENGE!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- Custom Painter for the Tag Shape (Keep as is) ---
class _TagPainter extends CustomPainter {
  final Color color;
  _TagPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 10, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 10, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}