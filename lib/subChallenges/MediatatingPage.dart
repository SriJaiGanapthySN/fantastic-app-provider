import 'package:flutter/material.dart';
import 'dart:ui';

import 'MeditateTask.dart'; // For blur effect (optional, not used here but kept for reference)

class MeditationActionScreen extends StatefulWidget {
  final String imageUrl; // Background image URL

  const MeditationActionScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  State<MeditationActionScreen> createState() => _MeditationActionScreenState();
}

class _MeditationActionScreenState extends State<MeditationActionScreen> {
  bool _isPlaying = false; // State for play/pause button
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  // Adjusted sheet sizes to ensure "READ THIS LETTER" is clearly visible initially
  final double _minSheetSize = 0.13;
  final double _initialSheetSize = 0.13;
  final double _maxSheetSize = 0.85; // How high it can be dragged

  // --- Hardcoded Text Content (from images) ---
  final String title = "Your First Action";
  final String subtitle = "Create a Meditation Habit";
  final String durationText = "(2 minutes)";
  final String letterDate = "December 25, 2024"; // From second image crop
  final String letterReadTime = "3 min";       // From second image crop
  final String letterSalutation = "RDX,";        // From second image crop
  final String letterTitle = "Create a meditation habit."; // From second image crop
  // Combined multi-line text from second image crop
  final String letterBody = "A research article released by Stanford showed that ‘a wandering mind is a less caring mind’. A clear benefit of meditation is improved focus...";

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body content behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Icons exactly as shown in the first image header
          IconButton(
            // This icon seems adaptive based on play state in the image, but the specific icon is 'equalizer' or similar
            icon: const Icon(Icons.equalizer_rounded, color: Colors.white), // Using equalizer as placeholder
            onPressed: () { /* TODO: Action */ },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () { /* TODO: Action */ },
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white), // Check icon (not outlined)
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> GoalScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () { /* TODO: Action */ },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Image (Full Screen)
          Positioned.fill(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) {
                // Provide a fallback background color and icon on error
                return Container(color: Colors.blueGrey[800], child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 60)));
              },
            ),
          ),

          // 2. Gradient Overlay for Text Readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent, Colors.black.withOpacity(0.35)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0], // Adjust stops for desired fade
                ),
              ),
            ),
          ),

          // 3. Overlay Text Content (Title, Subtitle, Duration)
          Positioned(
            // Position below status bar and AppBar space
            top: topPadding + kToolbarHeight + (screenHeight * 0.03),
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title, // Hardcoded title
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18, // Adjusted size based on image
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle, // Hardcoded subtitle
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30, // Adjusted size based on image
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 7)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  durationText, // Hardcoded duration
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 19, // Adjusted size based on image
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)],
                  ),
                ),
              ],
            ),
          ),

          // 4. Central Play/Pause Button
          Positioned(
            // Position calculation for rough vertical/horizontal center
            top: screenHeight * 0.5 - 45, // Adjust 45 (half button size + offset)
            left: screenWidth * 0.5 - 45,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    // TODO: Add actual play/pause logic
                  });
                },
                child: Container(
                  width: 90, // Slightly larger based on image proportion
                  height: 90,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE91E63), // Pink color
                      shape: BoxShape.circle,
                      // Adding subtle inner border as seen in image
                      border: Border.all(color: Colors.black.withOpacity(0.15), width: 3.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 5)
                        )
                      ]
                  ),
                  child: Center(
                    child: Icon(
                      // Use the pause/play icons shown in the images
                      _isPlaying ? Icons.pause_rounded : Icons.equalizer_rounded, // equalizer icon shown in image 1
                      color: Colors.white,
                      size: 55, // Adjusted size
                    ),
                  ),
                )
            ),
          ),

          // 5. Draggable Bottom Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _initialSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [ // Match shadow from image 2
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 18.0,
                      spreadRadius: 0.0, // Less spread
                      offset: Offset(0, -6), // Slightly larger offset
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 15.0), // Adjusted padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Collapsed View Handle/Hint ---
                          Center(
                            child: Column(
                              children: [
                                const Icon( // Triangle icon from image 1
                                  Icons.arrow_drop_up, // This is the closest standard icon
                                  color: Color(0xFFE91E63), // Pink color for handle icon
                                  size: 28,
                                ),
                                // const SizedBox(height: 0), // Reduce space
                                Text(
                                  "READ THIS LETTER",
                                  style: TextStyle(
                                    color: Colors.grey[700], // Darker grey
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24), // Space before letter content

                          // --- Expanded View (Letter Content) ---
                          const SizedBox(height: 20),

                          // Date and Read Time Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                letterDate, // Hardcoded date
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13.5, // Slightly adjusted size
                                ),
                              ),
                              Text(
                                letterReadTime, // Hardcoded read time
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Salutation
                          Text(
                            letterSalutation, // Hardcoded salutation
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16), // Increased spacing

                          // Letter Title
                          Text(
                            letterTitle, // Hardcoded letter title
                            style: const TextStyle(
                              color: Color(0xFF212121), // Near black
                              fontSize: 24, // Adjusted size
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              fontFamily: 'serif', // Using serif font like image
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Letter Body
                          Text(
                            letterBody, // Hardcoded letter body
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 16.5, // Slightly larger body text
                              height: 1.55,
                              fontFamily: 'serif', // Using serif font like image
                            ),
                          ),
                          const SizedBox(height: 40), // Padding at the bottom
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}