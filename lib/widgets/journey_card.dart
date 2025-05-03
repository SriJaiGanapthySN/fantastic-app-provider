import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import '../utils/blur_container.dart';

class JourneyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String progress;
  final String? imageUrl;
  final VoidCallback? onTap;

  const JourneyCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate dynamic dimensions
    final cardHeight = screenHeight * 0.20; // 20% of screen height
    final cardWidth = screenWidth - 32; // Full width minus padding
    final borderRadius = screenWidth * 0.05; // 5% of screen width
    final padding = screenWidth * 0.025; // 2.5% of screen width
    final titleFontSize = screenWidth * 0.05; // 5% of screen width
    final subtitleFontSize = screenWidth * 0.03; // 3% of screen width
    final progressCircleSize = screenWidth * 0.1; // 10% of screen width
    final progressFontSize = screenWidth * 0.035; // 3.5% of screen width
    final labelFontSize = screenWidth * 0.035; // 3.5% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: const DecorationImage(
            image: AssetImage('assets/images/06714b8cb3d074a22b22b30b25ad5ac5.png'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
              const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Image with Error Handling
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder_journey.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            // Top "Current Journey" Label
            Positioned(
              top: padding * 0.8,
              left: padding,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding * 0.8, vertical: padding * 0.4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                ),
                child: Text(
                  'Current Journey',
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            // Bottom Content Container with Glass Effect
            Positioned(
              left: padding,
              right: padding,
              bottom: padding * 0.4,
              child: BlurContainer(
                blur: 10,
                borderRadius: borderRadius * 0.5,
                color: Colors.white.withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            " "+title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: padding * 0.15),
                          Text(
                            ' '+subtitle,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: padding * 0.4),
                    Container(
                      width: progressCircleSize,
                      height: progressCircleSize,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(253, 255, 255, 255),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.all(padding * 0.4),
                            child: Text(
                              progress,
                              style: TextStyle(
                                fontSize: progressFontSize,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 