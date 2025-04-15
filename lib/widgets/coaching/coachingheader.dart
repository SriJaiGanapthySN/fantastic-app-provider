import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final Map<String,dynamic> coaching;
  const HeaderSection({super.key,required this.coaching});
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            coaching["imageUrl"],
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          alignment: Alignment.topLeft,
          child:  Text(
            coaching["title"],
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            coaching["subtitle"],
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: colorFromString(coaching["color"]),
            padding: const EdgeInsets.symmetric(horizontal: 145, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(
            Icons.play_arrow,
            size: 35,
          ),
          label: const Text(
            "Play",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
