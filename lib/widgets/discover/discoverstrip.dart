import 'package:fantastic_app_riverpod/widgets/discover/addDiscoveryTile.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Add this import for ImageFilter

class Discoverstrip extends StatelessWidget {
  Discoverstrip({super.key, required this.currentData, required this.email});
  final String email;

  final List<Map<String, dynamic>> currentData;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        // The scrollable content
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: screenWidth * 0.3),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.178),
                      spreadRadius: 1.5,
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: screenHeight * 0.27,
                    child: Stack(
                      children: [
                        // Modified to match image height instead of filling
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height:
                                screenHeight * 0.26, // Match the image height
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Explore Learning Paths",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Choose a path to begin",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width:
                                    currentData.length * (screenWidth * 0.462),
                                height: screenHeight * 0.16,
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: currentData.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: AddDiscoveryTile(
                                            tile: currentData[index],
                                            email: email,
                                          ),
                                        );
                                      },
                                    ),
                                    // Add an image loading indicator
                                    Image.network(
                                      currentData.isNotEmpty &&
                                              currentData[0]
                                                  .containsKey('imageUrl')
                                          ? currentData[0]['imageUrl'] ?? ''
                                          : '',
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          // Image is loaded
                                          return const SizedBox.shrink();
                                        }
                                        // Show loading indicator while image loads
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Hide the widget on error
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
