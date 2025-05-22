import 'package:flutter/material.dart';

import 'TimePage.dart'; // Assuming TimePage.dart exists and is correct

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

  // --- Helper function to show the "Why" dialog (Unchanged from previous responsive version) ---
  void _showWhyDialog(BuildContext context) {
    const Color dialogPrimaryColor = Color(0xFF009688);
    const Color dialogTextColor = Color(0xFF616161);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          actionsPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 20.0),
          title: const Text(
            "Why am I doing this?",
            style: TextStyle(
              color: dialogPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challengeData['subtitle'] ?? 'Complete the challenge.',
                  style: const TextStyle(fontSize: 15.5, color: dialogTextColor, height: 1.4),
                ),
                const SizedBox(height: 15.0),
                Text(
                  challengeData['whyDescription'] ??
                      "Taking on this challenge helps build positive habits and improve well-being.",
                  style: const TextStyle(fontSize: 15.5, color: dialogTextColor, height: 1.4),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, color: dialogPrimaryColor, size: 20),
                  SizedBox(width: 8.0),
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
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper function to show the "Download" dialog (Unchanged from previous responsive version) ---
  void _showDownloadDialog(BuildContext context) {
    const Color dialogHeaderColor = Color(0xFFE91E63);
    const Color dialogTitleColor = Color(0xFFD81B60);
    const Color dialogTextColor = Color(0xFF424242);

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
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: dialogHeaderColor,
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/download_placeholder.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cloud_download_outlined,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Almost there!",
                            style: TextStyle(
                              color: dialogTitleColor,
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
                          const SizedBox(height: 25.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              child: const Text(
                                "DOWNLOAD NOW",
                                style: TextStyle(
                                  color: dialogTitleColor,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Helper function to show the "Stop Challenge" dialog (Unchanged from previous responsive version) ---
  void _showStopChallengeDialog(BuildContext context) {
    const Color dialogTitleColor = Color(0xFF26A69A);
    const Color dialogTextColor = Color(0xFF424242);
    const Color secondaryButtonColor = Color(0xFF757575);
    final String imageUrl = challengeData['imageUrl'] ?? '';
    final String title = challengeData['title'] ?? '';
    final String objectId = challengeData['objectId'] ?? '';

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
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/journey_map_placeholder.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.map_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Ready to stop your challenge?",
                            style: TextStyle(
                              color: dialogTitleColor,
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
                          const SizedBox(height: 25.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                child: const Text(
                                  "STOP CHALLENGE",
                                  style: TextStyle(
                                    color: dialogTitleColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengeTimeScreen(imageUrl: imageUrl,title: title,objectId: objectId,)));
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                child: const Text(
                                  "DON'T SWITCH",
                                  style: TextStyle(
                                    color: secondaryButtonColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                onPressed: () {
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
            // --- Top Section: Tag and Close Button --- (Stays fixed at the top)
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
            const SizedBox(height: 20), // Original spacing

            // --- Title --- (Stays fixed below top section)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text( // Title text directly
                title,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: titleTextColor, height: 1.3),
              ),
            ),
            const SizedBox(height: 12.0), // Original spacing between title and description text

            // --- SCROLLABLE Description Section ---
            Expanded( // Allows this section to take available vertical space and scroll
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontal padding for description
                child: Text(
                  description,
                  style: TextStyle(fontSize: 16, color: bodyTextColor, height: 1.4),
                ),
              ),
            ),
            // This SizedBox was originally after the Padding that contained both Title and Description.
            // It provides space before the image or the bottom bar if no image.
            const Spacer(),


            // --- Image (Conditional Display) --- (Stays fixed below scrollable description)
            if (hasValidImageUrl)
              Padding(
                // The SizedBox(height: 20.0) above provides the primary spacing.
                // The original Padding(top: 10.0) for the image adds to this.
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Fixed height as per original
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
            // If no image, the SizedBox(height: 20.0) above provides spacing before the bottom container.
            // The Expanded widget for the description handles pushing the bottom container down.

            // --- Fixed White Bottom Container --- (Stays fixed at the screen bottom)
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, color: primaryActionColor, size: 22),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryButtonBg,
                      foregroundColor: primaryActionColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showWhyDialog(context),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryActionColor,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showDownloadDialog(context),
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