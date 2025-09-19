import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- REQUIRED: Adjust these import paths to match your project structure ---
import '../providers/challengeProvider.dart'; // For Skill, SkillGoal, getSkillByTrackId, etc.
import '../providers/discover_provider.dart'; // For persona state
// Assuming your auth provider is here (used alias to avoid potential name clashes)

// --- OPTIONAL: Persistence Imports (replace/remove as needed) ---
// Example using SharedPreferences:
// import 'package:shared_preferences/shared_preferences.dart';
// Example using Firestore:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // If using Firebase Auth for user ID

//----------------------------------------------------------------------
// GoalScreen Widget
//----------------------------------------------------------------------

class GoalScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  final String skillTrackId; // Expecting only the ID

  const GoalScreen({
    super.key,
    required this.skillTrackId,
  });

  @override
  ConsumerState<GoalScreen> createState() =>
      _GoalScreenState(); // Changed return type
}

//----------------------------------------------------------------------
// _GoalScreenState
//----------------------------------------------------------------------

class _GoalScreenState extends ConsumerState<GoalScreen> {
  // Changed to ConsumerState
  // State variables
  Skill? _skill;
  SkillGoal? _skillGoal;
  bool _isLoading = true;
  String? _error;
  int _completedCount =
      0; // Tracks completed steps for this specific goal instance
  bool _listenerSetup = false; // Flag to ensure listener is set up only once

  @override
  void initState() {
    super.initState();
    _fetchGoalData();
  }

  // --- Function to fetch Skill, SkillGoal, and load saved progress ---
  Future<void> _fetchGoalData() async {
    if (!mounted) return; // Check if the widget is still in the tree
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load saved progress from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _completedCount = prefs.getInt('progress_${widget.skillTrackId}') ?? 0;

      // Fetch Skill and SkillGoal details concurrently using your provider functions
      // Get current persona state
      final isParentMode = ref.read(personaProvider).isParentMode;

      final results = await Future.wait([
        getSkillByTrackId(widget.skillTrackId, isParentMode: isParentMode),
        getSkillGoalByTrackId(widget.skillTrackId, isParentMode: isParentMode),
      ]);

      if (!mounted) return; // Check again after async operation

      final fetchedSkill = results[0] as Skill?;
      final fetchedSkillGoal = results[1] as SkillGoal?;

      if (fetchedSkill != null && fetchedSkillGoal != null) {
        setState(() {
          _skill = fetchedSkill;
          _skillGoal = fetchedSkillGoal;
          // Sanity check: Ensure loaded progress doesn't exceed the goal's target value
          if (_skillGoal!.value > 0 && _completedCount > _skillGoal!.value) {
            _completedCount = _skillGoal!.value;
            // Save corrected count
            prefs.setInt('progress_${widget.skillTrackId}', _completedCount);
          }
          _isLoading = false;
        });
      } else {
        // Handle cases where skill or goal data couldn't be found
        setState(() {
          _error = 'Goal details not found for ID: ${widget.skillTrackId}.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (!mounted) return; // Check again after catching error
      print('Error fetching goal data: $e\n$stackTrace');
      setState(() {
        _error = 'Failed to load goal details. Please try again.';
        _isLoading = false;
      });
    }
  }

  // --- Function to handle button press, save progress, and navigate on completion ---
  Future<void> _markAsDone() async {
    // Ensure data is loaded and goal is not already achieved
    if (_skillGoal == null || _completedCount >= _skillGoal!.value) return;

    final newCount = _completedCount + 1;
    final bool goalJustCompleted = newCount >= _skillGoal!.value;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('progress_${widget.skillTrackId}', newCount);
      if (mounted) {
        setState(() {
          _completedCount = newCount;
        });

        debugPrint(
            "Marked day $_completedCount as complete for ${widget.skillTrackId}. Goal completed: $goalJustCompleted.");

        // --- Show Feedback SnackBar ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalJustCompleted
                ? 'Congratulations! Goal Achieved!'
                : 'Day $_completedCount marked complete! Keep going!'),
            duration: const Duration(seconds: 2),
            backgroundColor: goalJustCompleted ? Colors.green[700] : null,
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Error saving progress: $e\n$stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving progress: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Function to handle starting the challenge ---
  Future<void> _startChallenge() async {
    if (_completedCount > 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('progress_${widget.skillTrackId}', 1);
      if (mounted) {
        setState(() {
          _completedCount = 1;
        });
      }
    } catch (e) {
      print("Error starting challenge: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error starting challenge: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Function to handle restarting the challenge ---
  Future<void> _restartChallenge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('progress_${widget.skillTrackId}', 0);
      if (mounted) {
        setState(() {
          _completedCount = 0;
        });
      }
    } catch (e) {
      print("Error restarting challenge: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error restarting challenge: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Helper method to build the circular progress indicators ---
  Widget _buildProgressIndicator(
      int number, bool isCompleted, Color completedColor) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 3), // Add slight spacing
      decoration: BoxDecoration(
        color: isCompleted ? completedColor : Colors.grey[200],
        shape: BoxShape.circle,
        border: !isCompleted
            ? Border.all(color: Colors.grey[350]!, width: 1.5)
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check_rounded, // Use a rounded check
                color: Colors.white,
                size: 22,
              )
            : Text(
                '$number',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Set up persona listener only once
    if (!_listenerSetup) {
      ref.listen<PersonaState>(personaProvider, (previous, next) {
        if (previous?.isParentMode != next.isParentMode) {
          print(
              '🔄 Persona changed in MeditateTask, refetching goal data. Parent mode: ${next.isParentMode}');
          _fetchGoalData();
        }
      });
      _listenerSetup = true;
    }

    // Define colors used in the UI
    const Color primaryGreen = Color(0xFF00695C); // Tealish green
    const Color buttonGreen =
        Color(0xFF00BFA5); // Brighter teal/aqua for button & highlights

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white), // White spinner
        ),
      );
    }

    if (_error != null || _skill == null || _skillGoal == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[200], size: 60),
              const SizedBox(height: 20),
              Text(
                _error ??
                    'An unexpected error occurred. Could not load goal details.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _fetchGoalData, // Allow user to retry fetching data
              ),
            ],
          ),
        ),
      );
    }

    final bool isGoalAchieved = _completedCount >= _skillGoal!.value;
    final int totalDays = _skillGoal!.value;

    return Scaffold(
      backgroundColor: primaryGreen, // Set the background for the whole screen
      appBar: AppBar(
        backgroundColor: Colors
            .transparent, // Make AppBar transparent to show scaffold background
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white), // Use iOS style back arrow
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isLoading
              ? 'Loading Goal...'
              : (_skillGoal?.title ?? 'Goal Details'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Center the title
        actions: [
          // Show share button only if data is loaded successfully
          if (!_isLoading &&
              _error == null &&
              _skill != null &&
              _skillGoal != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              tooltip: 'Share Goal',
              onPressed: () {
                // You might want to share the goal title, description, or a link.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Share feature not implemented yet.')),
                );
              },
            ),
          const SizedBox(width: 8), // Add some padding to the right
        ],
      ),
      body: Column(
        // Main layout: Green top part, White bottom part
        children: [
          // --- Top Green Content Area ---
          Expanded(
            flex: 3, // Give more space to the top area
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                  24.0, 10.0, 24.0, 20.0), // Adjust padding
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center content horizontally
                children: [
                  // Skill Icon
                  if (_skill!.iconUrl.isNotEmpty) // Check if icon URL is valid
                    SvgPicture.network(
                      _skill!.iconUrl,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      height: 70, // Slightly larger icon
                      placeholderBuilder: (context) => const SizedBox(
                        width: 70,
                        height: 70,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white54)),
                      ),
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.bubble_chart_outlined, // Fallback icon
                              color: Colors.white.withOpacity(0.7),
                              size: 70),
                    )
                  else // Provide a default icon if URL is empty
                    Icon(Icons.bubble_chart_outlined,
                        color: Colors.white.withOpacity(0.7), size: 70),

                  const SizedBox(height: 20),

                  // Goal Title
                  Text(
                    _skillGoal!.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26, // Adjust font size
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Goal Description
                  Text(
                    _skillGoal!.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.white.withOpacity(0.9), // Slightly less bright
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Informational Text
                  Text(
                    "Complete this goal $totalDays time${totalDays == 1 ? '' : 's'} to build the habit!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(), // Pushes content slightly up if space allows
                ],
              ),
            ),
          ),

          // --- Bottom White Area ---
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0), // Larger border radius
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  // Add a subtle shadow for depth
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  )
                ]),
            padding: const EdgeInsets.fromLTRB(
                20.0, 28.0, 20.0, 32.0), // Adjust padding
            child: Builder(
              builder: (context) {
                // --- If not started, show Start Challenge button ---
                if (_completedCount == 0) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: _startChallenge,
                    child: const Text("Start Challenge"),
                  );
                }
                // --- If goal is achieved, show Restart/New Challenge options ---
                if (isGoalAchieved) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: _restartChallenge,
                        child: const Text("Restart Challenge"),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: startNewChallenge,
                        child: const Text("Start New Challenge"),
                      ),
                    ],
                  );
                }
                // --- Default: In-progress state ---
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Progress Title
                    Text(
                      totalDays > 0
                          ? "Your Progress ($_completedCount/$totalDays)"
                          : "Goal Progress", // Fallback if totalDays is 0
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Progress Indicators Row (handle potential overflow with Wrap)
                    if (totalDays > 0) // Only show if there's a goal value > 0
                      Wrap(
                        // Use Wrap for better handling of many indicators
                        alignment: WrapAlignment.center,
                        spacing: 6.0, // Horizontal space between indicators
                        runSpacing: 8.0, // Vertical space if they wrap
                        children: List.generate(totalDays, (index) {
                          bool completed = index < _completedCount;
                          return _buildProgressIndicator(
                            index + 1, // Day number (1-based)
                            completed,
                            buttonGreen, // Use button color for completed state
                          );
                        }),
                      )
                    else // Show a message if the goal value is 0 or invalid
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "No specific duration set for this goal.",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            buttonGreen, // Always enabled in progress
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                            double.infinity, 52), // Full width, fixed height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              16.0), // More rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 17, // Slightly larger text
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        elevation: 3,
                      ),
                      onPressed: _markAsDone,
                      child: const Text("Mark Today as Complete"),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void startNewChallenge() {
    // Implementation of startNewChallenge method
  }
}
