// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/providers/discover_provider.dart';
import 'package:fantastic_app_riverpod/screens/journey_screen.dart';
import 'package:fantastic_app_riverpod/screens/coaching/coachingscreenreveal.dart';
import 'package:fantastic_app_riverpod/screens/guidedcoaching/guidedcoachingsecondlevel.dart';

class AddDiscoveryTile extends ConsumerWidget {
  const AddDiscoveryTile({
    super.key,
    required this.tile,
    required this.email,
  });

  final Map<String, dynamic> tile;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final selectedButtonIndex =
        ref.watch(discoverUIStateProvider).selectedButtonIndex;

    // Extract data from tile
    final String url = tile['imageUrl'] ?? 'assets/images/default.jpg';
    final String title = tile['title'] ?? tile['name'] ?? 'No Title';
    final String subtitle = tile['subtitle'] ?? 'No Subtitle';
    final String timestamp = tile['timestamp']?.toString() ?? '0';

    return InkWell(
      onTap: () {
        // Navigate to appropriate screen based on selected button index
        switch (selectedButtonIndex) {
          case 0: // Journeys
            Navigator.pushNamed(
              context,
              '/journey-details',
              arguments: {
                'journeyId': tile['objectId'] ?? '',
                'email': email,
              },
            );
            break;
          case 1: // Coaching
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Coachingscreenreveal(
                  email: email,
                  coachingSeriesId: tile["objectId"] ?? '',
                  coachingSeries: tile,
                ),
              ),
            );
            break;
          case 2: // Guided Activities
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Guidedcoachingsecondlevel(
                  email: email,
                  category: tile,
                ),
              ),
            );
            break;
          default:
            // Default to journey screen if index is unknown
            Navigator.pushNamed(
              context,
              '/journey-details',
              arguments: {
                'journeyId': tile['objectId'] ?? '',
                'email': email,
              },
            );
        }
      },
      child: Column(
        children: [
          // Background Image Container
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0),
                padding: EdgeInsets.all(screenWidth * 0.03),
                height: screenHeight * 0.12,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: null,
                ),
                child: Material(
                  shadowColor: Colors.black,
                  elevation: 20,
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
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.amberAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
