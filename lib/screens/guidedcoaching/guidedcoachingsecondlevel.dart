import 'package:fantastic_app_riverpod/services/guided_activities.dart';
import 'package:fantastic_app_riverpod/widgets/common/stackcard.dart';
import 'package:fantastic_app_riverpod/widgets/guidedcoaching/guidedcoachingtile.dart';
import 'package:flutter/material.dart';

class Guidedcoachingsecondlevel extends StatefulWidget {
  final String email;
  final Map<String, dynamic> category;

  const Guidedcoachingsecondlevel({
    super.key,
    required this.email,
    required this.category,
  });

  @override
  State<Guidedcoachingsecondlevel> createState() =>
      _GuidedcoachingsecondlevelState();
}

class _GuidedcoachingsecondlevelState extends State<Guidedcoachingsecondlevel> {
  final GuidedActivities _guidedActivities = GuidedActivities();
  bool _isLoading = true;
  List<Map<String, dynamic>> trainingData = [];

  @override
  void initState() {
    super.initState();
    _fetchTrainings(
        widget.category["trainingIds"]); // Fetch data on widget load
  }

  Future<void> _fetchTrainings(List<dynamic> ids) async {
    trainingData = await _guidedActivities.fetchTrainings(ids.cast<String>());
    setState(() {
      _isLoading = false; // Update UI after fetching data
    });
  }

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Set tile height and padding dynamically based on screen size
    final double tileHeight = screenHeight * 0.19;
    final double tilePadding = screenWidth * 0.02;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorFromString(widget.category["color"]),
                    Colors.transparent, // Add a second color
                  ],
                  // stops: [0.6, 1.0], // Now matches the length of 'colors'
                ),
              ),
              child: CustomScrollView(
                slivers: [
                  // SliverAppBar with title at the top
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: screenHeight * 0.25, // 25% of screen height
                    backgroundColor: colorFromString(
                        widget.category["color"]), // AppBar background color
                    title: Text(
                      widget.category["name"],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Image.network(
                            widget.category["bigImageUrl"],
                            fit: BoxFit.cover,
                          ),
                          // Applying blur effect only on the lower part of the image
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: screenHeight *
                                  0.1, // Height of the blurred edge
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colorFromString(widget.category["color"]),
                                  ],
                                  // stops: [0.6, 1.0], // Creates the fade effect
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Body content with blue background
                  SliverToBoxAdapter(
                    child: Container(
                      color: colorFromString(
                          widget.category["color"]), // Page background color
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tilePadding,
                          vertical: tilePadding,
                        ),
                        child: Column(
                          children: List.generate(trainingData.length, (index) {
                            final training = trainingData[index];
                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical:
                                          tilePadding), // Optional spacing between tiles
                                  child: Material(
                                    elevation:
                                        8, // Controls the shadow intensity
                                    borderRadius: BorderRadius.circular(
                                        10), // Matches the tile's border radius
                                    shadowColor: Colors.black.withOpacity(
                                        0.4), // Shadow color and transparency
                                    child: Container(
                                        height: tileHeight,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              10), // Ensure shadow follows rounded corners
                                        ),
                                        child: Guidedcoachingtile(
                                            url: training['imageUrl'] ??
                                                'assets/images/default.jpg', // Fallback image
                                            title:
                                                training['name'] ?? 'No Title',
                                            timestamp:
                                                '${5 ?? 'N/A'} min', // Duration from data
                                            color: training["color"],
                                            subtitle: training["subtitle"],
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VerticalStackedCardScreen(
                                                          training: training),
                                                ),
                                              );
                                            })),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
