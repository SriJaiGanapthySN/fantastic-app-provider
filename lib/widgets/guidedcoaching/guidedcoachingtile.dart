import 'package:flutter/material.dart';

class Guidedcoachingtile extends StatefulWidget {
  const Guidedcoachingtile({
    super.key,
    required this.url,
    required this.title,
    required this.timestamp,
    this.subtitle,
    required this.color,
    this.onTap,
  });

  final String url;
  final String title;
  final String timestamp;
  final String? subtitle; // Optional subtitle
  final VoidCallback? onTap;
  final String color;

  @override
  _Guidedcoachingtile createState() => _Guidedcoachingtile();
}

class _Guidedcoachingtile extends State<Guidedcoachingtile> {
  Color colorFromString(String colorString) {
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('0xFF$hexColor'));
    } else {
      throw FormatException('Invalid color string format');
    }
  }

  double calculateTextHeight(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 3, // Limit to 3 lines
    )..layout(maxWidth: maxWidth);
    return textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double tileHeight = screenHeight * 0.19; // 19% of screen height
    final double titleFontSize = screenWidth * 0.065; // Title font size
    final double subtitleFontSize = screenWidth * 0.05; // Subtitle font size
    final double timestampFontSize = screenWidth * 0.05; // Subtitle font size

    // Define text styles
    final TextStyle titleStyle = TextStyle(
      fontSize: titleFontSize,
      fontWeight: FontWeight.bold,
      height: 1.15,
    );

    final TextStyle subtitleStyle = TextStyle(
      fontSize: subtitleFontSize,
      fontWeight: FontWeight.normal,
      height: 1.15,
    );

    // Calculate text heights
    final double subtitleHeight = widget.subtitle != null
        ? calculateTextHeight(widget.subtitle!, subtitleStyle, screenWidth - 65)
        : 0.0;

    final double titleHeight =
        calculateTextHeight(widget.title, titleStyle, screenWidth - 60);

    // Calculate positions
    final double subtitleBottomMargin =
        tileHeight * 0.1; // 10% margin from bottom
    final double subtitleTopOffset =
        tileHeight - subtitleBottomMargin - subtitleHeight;
    final double titleTopOffset = subtitleTopOffset - titleHeight;

    // Timestamp position using MediaQuery for dynamic screen adjustments
    final double timestampTopOffset =
        screenHeight * 0.01; // 5% from the top of the screen
    final double timestampRightOffset =
        screenWidth * 0.02; // 5% from the top of the screen

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Background image with rounded corners
          Container(
            height: tileHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(widget.url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title
          Positioned(
            left: 20,
            right: 20,
            top: titleTopOffset,
            child: Text(
              widget.title,
              style: titleStyle.copyWith(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Subtitle
          if (widget.subtitle != null)
            Positioned(
              left: 20,
              right: 20,
              top: subtitleTopOffset,
              child: Text(
                widget.subtitle!,
                style: subtitleStyle.copyWith(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Timestamp badge with dynamic top position
          Positioned(
            right: timestampRightOffset,
            top: timestampTopOffset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.timestamp,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: timestampFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
