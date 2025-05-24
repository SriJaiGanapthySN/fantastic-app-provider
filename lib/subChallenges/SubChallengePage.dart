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

  // --- Helper function to show the "Why" dialog ---
  void _showWhyDialog(BuildContext context) {
    // Parent context's screenWidth is used as a base for dialog content scaling.
    // For dialog-specific dimensions like padding, dialogContext's width is used.

    const Color dialogPrimaryColor = Color(0xFF009688);
    const Color dialogTextColor = Color(0xFF616161);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogScreenWidth = MediaQuery.of(dialogContext).size.width;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Fixed radius
          ),
          backgroundColor: Colors.white,
          // Scaled dialog paddings
          titlePadding: EdgeInsets.fromLTRB(dialogScreenWidth * 0.06, dialogScreenWidth * 0.06, dialogScreenWidth * 0.06, dialogScreenWidth * 0.025), // ~24, 24, 24, 10
          contentPadding: EdgeInsets.symmetric(horizontal: dialogScreenWidth * 0.06, vertical: dialogScreenWidth * 0.025), // ~24, 10
          actionsPadding: EdgeInsets.fromLTRB(dialogScreenWidth * 0.06, dialogScreenWidth * 0.025, dialogScreenWidth * 0.06, dialogScreenWidth * 0.05), // ~24, 10, 24, 20

          title: Text(
            "Why am I doing this?",
            style: TextStyle(
              color: dialogPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: dialogScreenWidth * 0.05, // Original: 20.0
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challengeData['subtitle'] ?? 'Complete the challenge.',
                  style: TextStyle(fontSize: dialogScreenWidth * 0.04, color: dialogTextColor, height: 1.4), // Original: 15.5
                ),
                SizedBox(height: dialogScreenWidth * 0.0375), // Original: 15.0
                Text(
                  challengeData['whyDescription'] ??
                      "Taking on this challenge helps build positive habits and improve well-being.",
                  style: TextStyle(fontSize: dialogScreenWidth * 0.04, color: dialogTextColor, height: 1.4), // Original: 15.5
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: dialogScreenWidth * 0.0375, // Original: 15
                  vertical: dialogScreenWidth * (10/400),    // Original: 10
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, color: dialogPrimaryColor, size: dialogScreenWidth * 0.05), // Original: 20
                  SizedBox(width: dialogScreenWidth * 0.02), // Original: 8.0
                  Text(
                    "OK, GOT IT",
                    style: TextStyle(
                      color: dialogPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: dialogScreenWidth * 0.035, // Original: 14.0
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

  // --- Helper function to show the "Download" dialog ---
  void _showDownloadDialog(BuildContext context) {
    const Color dialogHeaderColor = Color(0xFFE91E63);
    const Color dialogTitleColor = Color(0xFFD81B60);
    const Color dialogTextColor = Color(0xFF424242);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogScreenWidth = MediaQuery.of(dialogContext).size.width;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Fixed
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0), // Fixed
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: dialogHeaderColor,
                    padding: EdgeInsets.symmetric(vertical: dialogScreenWidth * 0.0625), // Original: 25.0 -> 25/400
                    child: Center(
                      child: Image.asset(
                        'assets/images/download_placeholder.png',
                        height: dialogScreenWidth * 0.2, // Original: 80 -> 80/400
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.cloud_download_outlined,
                          size: dialogScreenWidth * 0.2, // Original: 80
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(dialogScreenWidth * 0.06, dialogScreenWidth * 0.06, dialogScreenWidth * 0.06, dialogScreenWidth * 0.05), // Original: 24,24,24,20
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Almost there!",
                            style: TextStyle(
                              color: dialogTitleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: dialogScreenWidth * 0.05, // Original: 20.0
                            ),
                          ),
                          SizedBox(height: dialogScreenWidth * 0.03), // Original: 12.0 -> 12/400
                          Text(
                            "Looks like we need to download this content before you begin your next adventure. We promise it'll be quick!",
                            style: TextStyle(
                              fontSize: dialogScreenWidth * 0.04, // Original: 15.5
                              color: dialogTextColor,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: dialogScreenWidth * 0.0625), // Original: 25.0
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: dialogScreenWidth * 0.0375, // Original: 15
                                  vertical: dialogScreenWidth * (10/400),    // Original: 10
                                ),
                              ),
                              child: Text(
                                "DOWNLOAD NOW",
                                style: TextStyle(
                                  color: dialogTitleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: dialogScreenWidth * 0.035, // Original: 14.0
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () {
                                _showStopChallengeDialog(context); // context from _showDownloadDialog
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

  // --- Helper function to show the "Stop Challenge" dialog ---
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
        final dialogScreenWidth = MediaQuery.of(dialogContext).size.width;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Fixed
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0), // Fixed
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: dialogScreenWidth * 0.0625), // Original: 25.0
                    child: Center(
                      child: Image.asset(
                        'assets/images/journey_map_placeholder.png',
                        height: dialogScreenWidth * 0.2, // Original: 80
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.map_outlined,
                          size: dialogScreenWidth * 0.2, // Original: 80
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(dialogScreenWidth * 0.06, dialogScreenWidth * 0.025, dialogScreenWidth * 0.06, dialogScreenWidth * 0.06), // Original: 24,10,24,24
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start, // Changed from .end for title/desc
                        children: [
                          Text(
                            "Ready to stop your challenge?",
                            style: TextStyle(
                              color: dialogTitleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: dialogScreenWidth * 0.05, // Original: 20.0
                            ),
                          ),
                          SizedBox(height: dialogScreenWidth * 0.03), // Original: 12.0
                          Text(
                            "If you join a new challenge or journey, your current challenge will be reset. You can restart your current challenge from the beginning at any time.",
                            style: TextStyle(
                              fontSize: dialogScreenWidth * 0.04, // Original: 15.5
                              color: dialogTextColor,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: dialogScreenWidth * 0.0625), // Original: 25.0
                          Column( // Buttons remain end-aligned
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: dialogScreenWidth * 0.025, // Original: 10 -> 10/400
                                    vertical: dialogScreenWidth * (8/400),   // Original: 8
                                  ),
                                ),
                                child: Text(
                                  "STOP CHALLENGE",
                                  style: TextStyle(
                                    color: dialogTitleColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: dialogScreenWidth * 0.035, // Original: 14.0
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengeTimeScreen(imageUrl: imageUrl,title: title,objectId: objectId,)));
                                },
                              ),
                              SizedBox(height: dialogScreenWidth * 0.02), // Original: 8.0 -> 8/400
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: dialogScreenWidth * 0.025, // Original: 10
                                    vertical: dialogScreenWidth * (8/400),   // Original: 8
                                  ),
                                ),
                                child: Text(
                                  "DON'T SWITCH",
                                  style: TextStyle(
                                    color: secondaryButtonColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: dialogScreenWidth * 0.035, // Original: 14.0
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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

    // Responsive dimensions for the main screen
    final double topBarPaddingTop = screenHeight * (15/800);       // Original: 15
    final double topBarPaddingLeft = screenWidth * (20/400);      // Original: 20
    final double topBarPaddingRight = screenWidth * (15/400);     // Original: 15

    final double tagBarHeight = screenHeight * (40/800);          // Original: 40
    final double tagBarHPadding = screenWidth * (18/400);         // Original: 18
    final double tagBarVPadding = tagBarHeight * (8/40);          // Original: 8 (relative to tagBarHeight)
    final double tagBarFontSize = screenWidth * (14/400);         // Original: 14

    final double closeIconSize = screenWidth * (28/400);          // Original: 28

    final double spacingAfterTagBar = screenHeight * (20/800);    // Original: 20

    final double titleDescHorizontalPadding = screenWidth * (20/400); // Original: 20 (for SingleChildScrollView)
    final double spacingAfterTitle = screenHeight * (12/800);     // Original: 12

    final double networkImageHeight = screenHeight * (200/800);   // Original: 200
    final double networkImageErrorIconSize = screenWidth * (50/400); // Original: 50

    final double bottomContainerPadding = screenWidth * (20/400); // Original: 20 (all sides)

    final double goalIconSize = screenWidth * (22/400);           // Original: 22
    final double goalTitleFontSize = screenWidth * (17/400);      // Original: 17
    final double goalSubtitleFontSize = screenWidth * (16/400);   // Original: 16
    final double horizontalSpacingSmall = screenWidth * (8/400);  // Original: 8

    final double spacingAfterGoalSubtitle = screenHeight * (10/800); // Original: 10
    final double spacingBeforeButtons = screenHeight * (30/800);  // Original: 30
    final double spacingBetweenButtons = screenHeight * (15/800); // Original: 15

    final double buttonHeight = screenHeight * (50/800);          // Original: 50
    final double buttonVerticalPadding = buttonHeight * (12/50);  // Original: 12 (relative to buttonHeight)
    final double buttonIconSize = screenWidth * (20/400);         // Original: 20 (for "WHY" button icon)
    final double buttonTextWhyFontSize = screenWidth * (14/400);  // Original: 14
    final double buttonTextBeginFontSize = screenWidth * (15/400);// Original: 15
    final double horizontalSpacingMedium = screenWidth * (10/400); // Original: 10 (for "WHY" button icon spacing)

    return Scaffold(
      backgroundColor: topBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Section: Tag and Close Button ---
            Padding(
              padding: EdgeInsets.only(top: topBarPaddingTop, left: topBarPaddingLeft, right: topBarPaddingRight),
              child: SizedBox(
                height: tagBarHeight,
                child: Stack(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomPaint(
                      painter: _TagPainter(color: primaryActionColor),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: tagBarHPadding, vertical: tagBarVPadding),
                        child: Text(
                          "Fabulous Challenge",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: tagBarFontSize),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Keep as is, ensures tight packing
                      icon: Icon(Icons.close, color: secondaryIconColor, size: closeIconSize),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ]),
              ),
            ),
            SizedBox(height: spacingAfterTagBar),

            // --- SCROLLABLE Title + Description Section ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: titleDescHorizontalPadding),
                child: Builder(
                  builder: (context) {
                    // These factors were already in the original code and are responsive.
                    final titleFontSize = screenWidth * 0.065;
                    final descriptionFontSize = screenWidth * 0.04;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: titleTextColor,
                          ),
                        ),
                        SizedBox(height: spacingAfterTitle),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: bodyTextColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // --- Image (Conditional Display) ---
            if (hasValidImageUrl)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: networkImageHeight,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: networkImageHeight,
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
                  height: networkImageHeight,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[500], size: networkImageErrorIconSize)),
                ),
              ),

            // --- Fixed White Bottom Container ---
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.all(bottomContainerPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, color: primaryActionColor, size: goalIconSize),
                      SizedBox(width: horizontalSpacingSmall),
                      Text("Goal", style: TextStyle(fontSize: goalTitleFontSize, fontWeight: FontWeight.bold, color: primaryActionColor)),
                    ],
                  ),
                  SizedBox(height: spacingAfterGoalSubtitle),
                  Text(
                    goalSubtitle,
                    style: TextStyle(fontSize: goalSubtitleFontSize, color: bodyTextColor.withOpacity(0.9), height: 1.4),
                  ),
                  SizedBox(height: spacingBeforeButtons),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryButtonBg,
                      foregroundColor: primaryActionColor,
                      elevation: 0,
                      minimumSize: Size(double.infinity, buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Fixed radius
                      padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                    ),
                    onPressed: () => _showWhyDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: buttonIconSize, color: primaryActionColor),
                        SizedBox(width: horizontalSpacingMedium),
                        Text(
                          "WHY AM I DOING THIS?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: buttonTextWhyFontSize,
                            color: primaryActionColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacingBetweenButtons),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryActionColor,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      minimumSize: Size(double.infinity, buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Fixed radius
                      padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                    ),
                    onPressed: () => _showDownloadDialog(context),
                    child: Text("BEGIN THE CHALLENGE!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: buttonTextBeginFontSize, letterSpacing: 0.5)),
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


// --- Custom Painter for the Tag Shape ---
class _TagPainter extends CustomPainter {
  final Color color;
  _TagPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Make the cut proportional to the tag's height for better scaling.
    // Original cut was 10px. If height was 40px, 10 is height/4.
    final double cut = size.height / 4;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}