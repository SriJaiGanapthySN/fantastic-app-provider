// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AddDiscoveryTile extends StatefulWidget {
  const AddDiscoveryTile({
    super.key,
    required this.tile,
    required this.email,
  });

  final Map<String, dynamic> tile;
  final String email;

  @override
  State<AddDiscoveryTile> createState() => _AddDiscoveryTileState();
}

class _AddDiscoveryTileState extends State<AddDiscoveryTile> {
  @override
  void initState() {
    super.initState();
  }

  bool infotapped = false;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Extract data from tile
    final String url = widget.tile['imageUrl'] ?? 'assets/images/default.jpg';
    final String title =
        widget.tile['title'] ?? widget.tile['name'] ?? 'No Title';
    final String subtitle = widget.tile['subtitle'] ?? 'No Subtitle';
    final String timestamp = widget.tile['timestamp']?.toString() ?? '0';

    return InkWell(
      onTap: () {
        // Navigate to the JourneyPlayScreen with email and tile data
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Journeyplayscreen(
        //       email: widget.email,
        //       data: widget.tile, // Pass the tile data if needed
        //     ),
        //   ),
        // );
      },
      child: Column(
        children: [
          // Background Image Container
          Stack(
            children: [
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 300), // Animation duration
                curve: Curves.easeInOut, // Smooth animation curve
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0),
                padding: EdgeInsets.all(screenWidth * 0.03),
                height: screenHeight * 0.12,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: infotapped
                      ? Colors.blue // Blue when info is tapped
                      : null, // Null to show image
                ),
                child: !infotapped
                    ? Material(
                        shadowColor: Colors.black,
                        elevation: 20, // Add elevation here
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.5,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Colors.amberAccent,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ],
          ),

          // Overlaying Title, Subtitle, Info Icon, and Percentage Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.01),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
