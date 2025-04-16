import 'package:flutter/material.dart';

class ImageCard1 extends StatelessWidget {
  final String imageAdd;
  final String text;
  final bool isSelected;

  const ImageCard1({
    super.key,
    required this.imageAdd,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16), // Padding inside the card
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          imageAdd,
                          width: screenWidth * 0.7,
                          height: screenHeight * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        text,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  CircleAvatar(
                    radius: screenWidth * 0.1,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: Icon(
                      Icons.check,
                      color: Colors.black,
                      size: screenWidth * 0.08,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
