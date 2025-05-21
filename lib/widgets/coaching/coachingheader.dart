import 'package:flutter/material.dart';
import 'package:fantastic_app_riverpod/screens/coaching/coachingPlay.dart';

class HeaderSection extends StatelessWidget {
  final Map<String, dynamic> coaching;
  final String email;
  final List<Map<String, dynamic>> coachingData;

  const HeaderSection({
    super.key,
    required this.coaching,
    required this.email,
    required this.coachingData,
  });

  Color colorFromString(String colorString) {
    // Remove the '#' if it's there and parse the hex color code
    String hexColor = colorString.replaceAll('#', '');

    // Ensure the string has the correct length (6 digits)
    if (hexColor.length == 6) {
      // Parse the color string to an integer and return it as a Color
      return Color(
          int.parse('0xFF$hexColor')); // Adding 0xFF to indicate full opacity
    } else {
      throw FormatException('Invalid color string format');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            coaching["imageUrl"],
            fit: BoxFit.cover,
            height:
                screenHeight * 0.35, // Responsive height instead of fixed 300
            width: double.infinity,
          ),
        ),
        SizedBox(height: screenHeight * 0.02), // Responsive spacing
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            coaching["title"],
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.07, // Responsive font size
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01), // Responsive spacing
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            coaching["subtitle"],
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.06, // Responsive font size
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02), // Responsive spacing
        ElevatedButton.icon(
          onPressed: () {
            if (coachingData.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Coachingplay(
                    email: email,
                    coachingSeries: coaching,
                    coachingData: coachingData.first,
                    coachings: coachingData,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: colorFromString(coaching["color"]),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.35, // Responsive horizontal padding
              vertical: screenHeight * 0.015, // Responsive vertical padding
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(
            Icons.play_arrow,
            size: screenWidth * 0.08, // Responsive icon size
          ),
          label: Text(
            "Play",
            style: TextStyle(
              fontSize: screenWidth * 0.045, // Responsive font size
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
