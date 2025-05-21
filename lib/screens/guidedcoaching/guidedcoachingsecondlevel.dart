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

  // Screen dimensions helper
  late double screenHeight;
  late double screenWidth;

  // Initialize responsive sizes
  void _initSizes(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

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
    _initSizes(context);

    // All measurements are now calculated proportionally
    final double tileHeight = screenHeight * 0.19;
    final double tilePadding = screenWidth * 0.02;
    final double cardBorderRadius = screenWidth * 0.025;
    final double cardElevation = screenHeight * 0.004;
    final double shadowOpacity = 0.4;
    final double blurHeight = screenHeight * 0.1;

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
                    Colors.transparent,
                  ],
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
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    iconTheme: IconThemeData(
                        color: Colors.white, size: screenWidth * 0.06),
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
                              height: blurHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colorFromString(widget.category["color"]),
                                  ],
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
                                      vertical: tilePadding),
                                  child: Material(
                                    elevation: cardElevation,
                                    borderRadius:
                                        BorderRadius.circular(cardBorderRadius),
                                    shadowColor:
                                        Colors.black.withOpacity(shadowOpacity),
                                    child: Container(
                                        height: tileHeight,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              cardBorderRadius),
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
