// sub_challenge_screen.dart
import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for Random

import 'package:flutter/material.dart';
// Remove flutter/widgets.dart import if flutter/material.dart is already imported
// import 'package:flutter/widgets.dart'; // Redundant if material.dart is used
import 'package:video_player/video_player.dart';

import 'SubChallengePage.dart'; // Import video_player

// --- IMPORTANT: Replace with your actual detail screen import ---
// import 'SubChallengePage.dart'; // Original Placeholder

// --- Data Structures ---
class Challenge {
  final String title;
  final String imageUrl;
  final Map<String, dynamic> originalData;

  Challenge({
    required this.title,
    required this.imageUrl,
    required this.originalData,
  });
}

class ChallengeSectionData {
  final String title;
  final List<Challenge> challenges;

  ChallengeSectionData({required this.title, required this.challenges});
}
// --- End Data Structures ---

class Sub_Challenge_Screen extends StatelessWidget {
  final List<Map<String, dynamic>> cardData;
  final List<String> _sectionTitles = const [
    'Mindset', 'Productivity', 'Hobbies', 'Movement',
    'Nutrition', 'Focus', 'Wellbeing', 'Growth'
  ];

  const Sub_Challenge_Screen({
    required this.cardData,
    super.key,
  });

  // --- Data Processing Logic (Keep as is) ---
  List<ChallengeSectionData> _processAndPartitionData() {
    // ... (Keep your existing implementation)
    final List<ChallengeSectionData> processedSections = [];
    final int totalItems = cardData.length;
    const int numSections = 8;
    int currentItemIndex = 0;

    if (totalItems == 0) {
      for (int i = 0; i < numSections; i++) {
        processedSections.add(ChallengeSectionData(
          title: _sectionTitles[i],
          challenges: [],
        ));
      }
      return processedSections;
    }

    for (int i = 0; i < numSections; i++) {
      final int baseCount = totalItems ~/ numSections;
      final int remainder = totalItems % numSections;
      final int countForThisSection = baseCount + (i < remainder ? 1 : 0);
      final int startIndex = currentItemIndex;
      int endIndex = currentItemIndex + countForThisSection;
      if (endIndex > totalItems) {
        endIndex = totalItems;
      }

      List<Challenge> challenges = [];
      if (startIndex < endIndex) {
        challenges = cardData.sublist(startIndex, endIndex).map((item) {
          final title = item['title'] as String? ?? 'Untitled Challenge';
          final imageUrl = item['imageUrl'] as String? ?? '';
          final bool isValidUrl = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

          return Challenge(
            title: title,
            imageUrl: isValidUrl ? imageUrl : '',
            originalData: item ?? {},
          );
        }).toList();
      }

      processedSections.add(ChallengeSectionData(
        title: _sectionTitles[i],
        challenges: challenges,
      ));
      currentItemIndex = endIndex;

      if (currentItemIndex >= totalItems && i < numSections - 1) {
        for (int j = i + 1; j < numSections; j++) {
          processedSections.add(ChallengeSectionData(
            title: _sectionTitles[j],
            challenges: [],
          ));
        }
        break;
      }
    }
    return processedSections;
  }
  // --- End Data Processing Logic ---

  // --- Helper to get all challenges in a flat list ---
  List<Challenge> _getAllChallenges() {
    final List<Challenge> allChallenges = [];
    for (final item in cardData) {
      final title = item['title'] as String? ?? 'Untitled Challenge';
      final imageUrl = item['imageUrl'] as String? ?? '';
      final bool isValidUrl = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
      allChallenges.add(Challenge(
        title: title,
        imageUrl: isValidUrl ? imageUrl : '',
        originalData: item ?? {},
      ));
    }
    return allChallenges;
  }
  // --- End Helper ---

  // --- Dice Roll Action ---
  void _rollDiceAndNavigate(BuildContext context) {
    final List<Challenge> allChallenges = _getAllChallenges();

    if (allChallenges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No challenges available to choose from!'), duration: Duration(seconds: 2))
      );
      return;
    }

    // Show the video dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) {
        return _DiceRollVideoDialog(
          allChallenges: allChallenges,
          // Pass the navigator from the parent context to handle navigation after pop
          parentNavigator: Navigator.of(context),
        );
      },
    );
  }
  // --- End Dice Roll Action ---


  @override
  Widget build(BuildContext context) {
    final List<ChallengeSectionData> displayedSections = _processAndPartitionData();
    const backgroundColor = Color(0xFFF0FAFD);
    const horizontalPadding = 18.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor, elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: Colors.grey[600]), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Challenge', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(18.0), child: Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text('Pick below or roll the dice', style: TextStyle(color: Colors.grey[600], fontSize: 14)))),
        toolbarHeight: 50,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90.0), // Adjusted padding to prevent FAB overlap issue
        children: [
          const Padding(padding: EdgeInsets.only(top: 8.0, bottom: 24.0), child: FlagWidget()),
          const HostChallengeBanner(horizontalPadding: horizontalPadding),
          const OrJoinDivider(),
          if (displayedSections.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text("No sections defined.")))
          else
            ...displayedSections.map((sectionData) {
              if (sectionData == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: ChallengeSection(
                  sectionData: sectionData,
                  horizontalPadding: horizontalPadding,
                ),
              );
            }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Updated onPressed
        onPressed: () => _rollDiceAndNavigate(context), // Call the new method
        backgroundColor: Colors.white, foregroundColor: Colors.blueGrey[400],
        elevation: 3.0, shape: const CircleBorder(), child: const Icon(Icons.casino_outlined),
      ),
    );
  }
}

// --- Video Dialog Widget ---
class _DiceRollVideoDialog extends StatefulWidget {
  final List<Challenge> allChallenges;
  final NavigatorState parentNavigator; // To navigate after closing the dialog

  const _DiceRollVideoDialog({
    required this.allChallenges,
    required this.parentNavigator,
  });

  @override
  State<_DiceRollVideoDialog> createState() => _DiceRollVideoDialogState();
}

class _DiceRollVideoDialogState extends State<_DiceRollVideoDialog> {
  VideoPlayerController? _controller;
  Timer? _timer;
  bool _isVideoInitialized = false;
  bool _navigationStarted = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // --- IMPORTANT: Make sure 'assets/videos/dice_roll.mp4' exists ---
      _controller = VideoPlayerController.asset('assets/videos/dice_roll.mp4');
      await _controller!.initialize();
      await _controller!.setLooping(true); // Loop the video
      await _controller!.play();
      setState(() {
        _isVideoInitialized = true;
      });

      // Start the timer *after* initialization
      _startTimer();

    } catch (e) {
      print("Error initializing video player: $e");
      // Handle error: Maybe close dialog and show snackbar?
      if (mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(widget.parentNavigator.context).showSnackBar( // Use parent context
            const SnackBar(content: Text('Error loading dice animation.'), duration: Duration(seconds: 2))
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      // Ensure navigation happens only once and the widget is still mounted
      if (mounted && !_navigationStarted) {
        _navigationStarted = true; // Mark navigation as started
        _selectAndNavigate();
      }
    });
  }


  void _selectAndNavigate() {
    // Stop video and dispose controller before navigating
    _controller?.pause();

    // Generate random index (0 to length - 1)
    final random = Random();
    final randomIndex = random.nextInt(widget.allChallenges.length);
    final selectedChallenge = widget.allChallenges[randomIndex];

    // Close the dialog *first*
    // Use root navigator if dialog context is different? Usually current context is fine.
    Navigator.of(context).pop();

    // THEN navigate to the detail screen using the parent context's navigator
    // Use addPostFrameCallback to ensure the build cycle is complete after pop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the parent screen is still mounted potentially, though less critical here
      widget.parentNavigator.push(
        MaterialPageRoute(
          builder: (_) => ChallengeDetailScreen(
            challengeData: selectedChallenge.originalData,
          ),
        ),
      );
    });
  }


  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer if dialog is disposed early
    // Dispose controller carefully, only if initialized
    _controller?.dispose().catchError((error) {
      print("Error disposing video controller: $error");
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero, // Remove default padding
      content: Container(
        width: 250, // Adjust size as needed
        height: 250, // Adjust size as needed
        child: _isVideoInitialized && _controller != null && _controller!.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        )
            : const Center(child: CircularProgressIndicator()), // Loading indicator
      ),
      // Optional: remove buttons if you only want the video
      actions: const <Widget>[], // Hide default buttons
      backgroundColor: Colors.transparent, // Make dialog background transparent
      elevation: 0, // Remove shadow
    );
  }
}


// --- FlagWidget (Keep as is) ---
class FlagWidget extends StatelessWidget {
  const FlagWidget({super.key});
  @override Widget build(BuildContext context) { return Center(child: Icon(Icons.flag, color: Colors.pink[400], size: 28.0)); }
}

// --- HostChallengeBanner (Keep as is) ---
class HostChallengeBanner extends StatelessWidget {
  final double horizontalPadding;
  const HostChallengeBanner({required this.horizontalPadding, super.key});

  @override Widget build(BuildContext context) {
    // ... (Keep your existing implementation)
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12.0),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // IMPORTANT: Ensure this image exists
                  Image.asset(
                    'assets/images/06714b8cb3d074a22b22b30b25ad5ac5.png',
                    height: 115, width: double.infinity, fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading host_banner.png: $error");
                      return Container(
                        height: 115,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Center(child: Icon(Icons.error_outline, color: Colors.grey[600])),
                      );
                    },
                  ),
                  const Padding(
                      padding: EdgeInsets.only(left: 24.0, right: 16.0),
                      child: Text(
                          'Host Your Own Live Challenge',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 6.0, color: Colors.black54, offset: Offset(1.5, 1.5))]
                          )
                      )
                  ),
                ]
            )
        )
    );
  }
}

// --- OrJoinDivider (Keep as is) ---
class OrJoinDivider extends StatelessWidget {
  const OrJoinDivider({super.key});
  @override Widget build(BuildContext context) { return Padding( padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0), child: Row( children: [ Expanded(child: Divider(thickness: 0.8, color: Colors.grey[350])), Padding( padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text( 'or', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500), ), ), Expanded(child: Divider(thickness: 0.8, color: Colors.grey[350])), ], ), ); }
}

// --- ChallengeSection (Keep as is) ---
class ChallengeSection extends StatelessWidget {
  final ChallengeSectionData sectionData;
  final double horizontalPadding;

  const ChallengeSection({
    required this.sectionData,
    required this.horizontalPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Keep your existing implementation)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: horizontalPadding, bottom: 14.0),
          child: Text(sectionData.title ?? 'Section',
              style: const TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, color: Color(0xFF444444))),
        ),
        if (sectionData.challenges != null && sectionData.challenges.isNotEmpty)
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sectionData.challenges.length,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemBuilder: (context, index) {
                final challenge = sectionData.challenges[index];
                if (challenge == null || challenge.originalData == null) {
                  print("Warning: Null challenge data at index $index in section '${sectionData.title}'");
                  return const SizedBox.shrink();
                }
                return ChallengeCard(
                  title: challenge.title,
                  imageUrl: challenge.imageUrl,
                  onTap: () {
                    if (challenge.originalData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // --- Make sure ChallengeDetailScreen accepts challengeData ---
                          builder: (_) => ChallengeDetailScreen(
                            challengeData: challenge.originalData!,
                          ),
                        ),
                      );
                    } else {
                      print("Cannot navigate: challenge.originalData is null for '${challenge.title}'");
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: Could not load challenge details.'), duration: Duration(seconds: 2))
                      );
                    }
                  },
                );
              },
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(left: horizontalPadding, bottom: 10),
            child: Text("No challenges in this section yet.", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}


// --- ChallengeCard (Keep as is) ---
class ChallengeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const ChallengeCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Keep your existing implementation)
    const cardWidth = 155.0;
    const cardHeight = 145.0;
    const cardBorderRadius = 14.0;
    // Added null check for imageUrl itself before checking content
    final bool hasValidImageUrl = imageUrl != null && imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Container(
      width: cardWidth, height: cardHeight, margin: const EdgeInsets.only(right: 14.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: Stack(
            children: [
              Positioned.fill(
                child: hasValidImageUrl
                    ? Image.network(
                  imageUrl, // No '!' needed due to check above
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(cardBorderRadius)),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!), value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading image $imageUrl: $error");
                    return Container(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(cardBorderRadius)),
                      child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 40)),
                    );
                  },
                )
                    : Container( // Case for null, empty, or invalid URL
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(cardBorderRadius)),
                  child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40)),
                ),
              ),
              // Overlay
              Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0.20), Colors.white.withOpacity(0.80)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.8]), borderRadius: BorderRadius.circular(cardBorderRadius)))),
              // Text
              Positioned(bottom: 12, left: 12, right: 12, child: Text(title ?? 'Challenge', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: Color(0xFF222222), height: 1.25))),
              // Tap Handler
              Positioned.fill(child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(cardBorderRadius), onTap: onTap, splashColor: Colors.black.withOpacity(0.1), highlightColor: Colors.black.withOpacity(0.05)))),
            ]
        ),
      ),
    );
  }
}

