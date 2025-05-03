import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// --- REQUIRED: Adjust these import paths ---
import '../providers/challengeProvider.dart';
// Example for persistence (replace with your actual implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // If using Firebase Auth for user ID
// import 'package:shared_preferences/shared_preferences.dart';

class GoalScreen extends StatefulWidget {
  final String skillTrackId; // Accept only the ID

  const GoalScreen({
    super.key,
    required this.skillTrackId,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  // State variables
  Skill? _skill;
  SkillGoal? _skillGoal;
  bool _isLoading = true;
  String? _error;
  int _completedCount = 0; // Tracks completed steps

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is first initialized
    _fetchGoalData();
  }

  // --- Function to fetch Skill, SkillGoal, and saved progress ---
  Future<void> _fetchGoalData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // --- TODO: LOAD SAVED PROGRESS ---
      // Replace this with your actual loading logic
      // Example using SharedPreferences:
      // final prefs = await SharedPreferences.getInstance();
      // _completedCount = prefs.getInt('progress_${widget.skillTrackId}') ?? 0;
      // Example using Firestore (adjust doc path):
      // final userId = FirebaseAuth.instance.currentUser?.uid;
      // if (userId != null) {
      //   final progressDoc = await FirebaseFirestore.instance
      //       .collection('userProgress')
      //       .doc('${userId}_${widget.skillTrackId}')
      //       .get();
      //   if (progressDoc.exists) {
      //     _completedCount = progressDoc.data()?['completedCount'] ?? 0;
      //   } else {
      //      _completedCount = 0; // Default if no record exists
      //   }
      // } else {
      //    _completedCount = 0; // Default if no user logged in
      // }
      // --- End Load Progress TODO ---


      // Fetch Skill and SkillGoal data concurrently
      final results = await Future.wait([
        getSkillByTrackId(widget.skillTrackId),
        getSkillGoalByTrackId(widget.skillTrackId),
      ]);

      if (!mounted) return;

      final fetchedSkill = results[0] as Skill?;
      final fetchedSkillGoal = results[1] as SkillGoal?;

      if (fetchedSkill != null && fetchedSkillGoal != null) {
        setState(() {
          _skill = fetchedSkill;
          _skillGoal = fetchedSkillGoal;
          // Ensure _completedCount doesn't exceed the goal value after loading
          if (_completedCount > _skillGoal!.value) {
            _completedCount = _skillGoal!.value;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Goal details not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('Error fetching goal data: $e');
      setState(() {
        _error = 'Failed to load goal details. Please try again.';
        _isLoading = false;
      });
    }
  }

  // --- Function to handle button press and save progress ---
  Future<void> _markAsDone() async {
    if (_skillGoal == null) return; // Should not happen if button is enabled

    if (_completedCount < _skillGoal!.value) {
      final newCount = _completedCount + 1;

      // --- TODO: SAVE PROGRESS ---
      // Replace this with your actual saving logic
      // Example using SharedPreferences:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setInt('progress_${widget.skillTrackId}', newCount);
      // Example using Firestore:
      // final userId = FirebaseAuth.instance.currentUser?.uid;
      // if (userId != null) {
      //   await FirebaseFirestore.instance
      //       .collection('userProgress')
      //       .doc('${userId}_${widget.skillTrackId}')
      //       .set({'completedCount': newCount, 'lastUpdated': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      // }
      // --- End Save Progress TODO ---

      // Update local state ONLY after successful save (or optimistically if preferred)
      setState(() {
        _completedCount = newCount;
      });

      debugPrint("Marked day $_completedCount as complete for ${widget.skillTrackId}.");

      // Optional: Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day $_completedCount marked as complete!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  // --- Helper method to build the progress indicators ---
  Widget _buildProgressIndicator(int number, bool isCompleted, Color completedColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCompleted ? completedColor : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
          Icons.check,
          color: Colors.white,
          size: 20,
        )
            : Text(
          '$number',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color primaryGreen = Color(0xFF00695C);
    const Color buttonGreen = Color(0xFF00BFA5); // Used for button and completed indicators

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isLoading ? 'Loading Goal...' : (_skillGoal?.title ?? 'Goal'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
        ],
      ),
      body: _buildBody(context, primaryGreen, buttonGreen),
    );
  }

  // --- Helper method to build the body based on state ---
  Widget _buildBody(BuildContext context, Color primaryGreen, Color buttonGreen) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null || _skill == null || _skillGoal == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'An unexpected error occurred.', // Display specific error or generic one
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchGoalData, // Retry button
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // --- Data is loaded successfully ---
    bool isGoalAchieved = _completedCount >= _skillGoal!.value;

    return Column(
      children: [
        // --- Top Green Content Area ---
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.network(
                  _skill!.iconUrl,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  height: 60,
                  placeholderBuilder: (context) => const SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(child: CircularProgressIndicator(color: Colors.white54)),
                  ),
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error_outline, color: Colors.white.withOpacity(0.7), size: 60),
                ),
                const SizedBox(height: 20),
                Text(
                  _skillGoal!.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _skillGoal!.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "${_skillGoal!.title} has been added to your ${_skillGoal!.value}-Day Challenge. Mark it as complete to progress your goal!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
                const Spacer(), // Push content towards center
              ],
            ),
          ),
        ),

        // --- Bottom White Area ---
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Do it ${_skillGoal!.value} time${_skillGoal!.value == 1 ? '' : 's'} to succeed",
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    _skillGoal!.value,
                        (index) {
                      bool completed = index < _completedCount;
                      return _buildProgressIndicator(
                        index + 1,
                        completed,
                        buttonGreen, // Use button color for completed state
                      );
                    }
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  disabledBackgroundColor: Colors.grey[400], // Style for disabled button
                ),
                onPressed: isGoalAchieved ? null : _markAsDone, // Disable if goal achieved
                child: Text(isGoalAchieved ? "Goal Achieved!" : "I have done this today!"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}