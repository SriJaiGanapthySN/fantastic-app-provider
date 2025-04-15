import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String imageAdd;
  final String text;
  final bool isSelected; // NEW: function that returns bool
  // NEW: callback to handle taps

  const ImageCard({
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

          bool selected = isSelected; // Call the function to get current selection

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Background Image
                  Image.asset(
                    imageAdd,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Dim overlay if selected
                  if (selected)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  // Tick icon with circular white background
                  if (selected)
                    Center(
                      child: CircleAvatar(
                        radius: screenWidth * 0.15, // small circle
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                          size: screenWidth * 0.1, // icon size
                        ),
                      ),
                    ),
                  // Text on top-left
                  Positioned(
                    top: screenHeight * 0.05,
                    left: screenWidth * 0.05,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.transparent,
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
