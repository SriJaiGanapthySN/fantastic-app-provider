import 'package:flutter/material.dart';

class CoachingFirstTile extends StatefulWidget {
  const CoachingFirstTile({
    super.key,
    required this.url,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.color,
  });

  final String url;
  final String title;
  final String? subtitle; // Optional subtitle
  final VoidCallback? onTap;
  final String color;

  @override
  _CoachingFirstTileState createState() => _CoachingFirstTileState();
}

class _CoachingFirstTileState extends State<CoachingFirstTile> {
  final GlobalKey _subtitleKey = GlobalKey(); // Key to measure subtitle widget
  final double _subtitleHeight = 0;

  Color colorFromString(String colorString) {
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('0xFF$hexColor'));
    } else {
      throw FormatException('Invalid color string format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double tileHeight = screenHeight * 0.5; // 50% of screen height
    final double horizontalMargin = screenWidth * 0.00;
    final double titleFontSize = screenWidth * 0.065; // 6.5% of screen width
    final double subtitleFontSize = screenWidth * 0.05; // 5% of screen width

    // Adjust title position based on subtitle height
    double titlePosition = tileHeight * 0.1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            height: tileHeight,
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(widget.url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorFromString(widget.color),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: horizontalMargin + 10,
            top: titlePosition, // Adjusted title position
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                // shadows: [
                //   Shadow(
                //     offset: const Offset(1, 1),
                //     blurRadius: 4,
                //     color: Colors.black.withOpacity(0.7),
                //   ),
                // ],
              ),
            ),
          ),
          if (widget.subtitle != null)
            Positioned(
              left: horizontalMargin + 10,
              right: horizontalMargin + 10,
              top: tileHeight * 0.2,
              child: Text(
                widget.subtitle!,
                key: _subtitleKey, // Attach the key to subtitle text
                style: TextStyle(
                  height: 1.15,
                  color: Colors.white,
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.normal,
                  // shadows: [
                  //   Shadow(
                  //     offset: const Offset(1, 1),
                  //     blurRadius: 4,
                  //     color: Colors.black.withOpacity(0.7),
                  //   ),
                  // ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}