import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../journey_screen.dart'; // Assuming JourneyScreen is in 'journey_screen.dart' one level up
import '../../models/skill.dart'; // Assuming Skill model is two levels up in models/
// import '../../models/skillTrack.dart'; // skillTrack is no longer an input, so this import might not be needed if the type isn't used elsewhere.
import '../../services/journey_service.dart'; // Assuming JourneyService is two levels up in services/

class Journeyscreenrevealtype7 extends StatefulWidget {
  final Map<String, dynamic> goalData; // Type explicitly Map<String, dynamic> as per goalDataResponse
  final Skill skill;
  final String email;
  // final skillTrack skilltrack; // Removed skilltrack parameter

  const Journeyscreenrevealtype7({
    super.key,
    required this.goalData,
    required this.skill,
    required this.email,
    // required this.skilltrack, // Removed from constructor
  });

  @override
  State<Journeyscreenrevealtype7> createState() => _Journeyscreenrevealtype3State();
}

class _Journeyscreenrevealtype3State extends State<Journeyscreenrevealtype7>
    with WidgetsBindingObserver {
  final String title = "Goal"; // Title can be dynamic if needed, but keeping it same as original
  final JourneyService _journeyService = JourneyService();
  Map<String, dynamic>? skillGoalData; // This will store the fetched/updated goal data
  bool isLoading = true;
  String? errorMessage;

  bool _hasCompletedTaskForToday = false;
  bool _isLoadingCompletionAction = false; // Used for "Complete Today" and "Restart"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize skillGoalData with the passed goalData to avoid null issues before fetch
    // skillGoalData = Map<String, dynamic>.from(widget.goalData); // Optional: use initial data for faster display
    _loadDailyStatusAndUpdateGoal();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!isLoading) { // Only refresh if not already loading
        _checkAndResetDailyStatus(); // Re-check daily status on resume
      }
    }
  }

  Future<void> _loadDailyStatusAndUpdateGoal() async {
    await _checkAndResetDailyStatus(); // Check local daily status first
    // Fetch the latest goal data using the goalId from the input widget.goalData
    // The input goalData["goalId"] should correspond to the objectId of the goal
    await fetchGoal(widget.email, widget.goalData["goalId"].toString());
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // Uses goalId from widget.goalData to make the key unique
  String _getPrefsKey() {
    return 'dailyCompletionStatus_${widget.goalData["goalId"]}';
  }

  Future<void> _checkAndResetDailyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastCompletionDateStr = prefs.getString(_getPrefsKey());
    final String todayStr = _getTodayDateString();

    if (mounted) {
      setState(() {
        if (lastCompletionDateStr == todayStr) {
          _hasCompletedTaskForToday = true;
        } else {
          _hasCompletedTaskForToday = false;
          // Optionally clear the pref if it's for a past date,
          // though current logic only sets it on completion for today.
          // if (lastCompletionDateStr != null) {
          //   prefs.remove(_getPrefsKey());
          // }
        }
      });
    }
  }

  Future<void> fetchGoal(String email, String id) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Assuming getSkillGoal can take the goalId (which is objectId)
      final data = await _journeyService.getSkillGoalByDocumentId(id);
      if (mounted) {
        setState(() {
          skillGoalData = data; // This will be a Map<String, dynamic> or null
          isLoading = false;
          if (skillGoalData == null) {
            errorMessage = 'No goal data found or failed to parse.';
          }
          // After fetching, re-check daily status against potentially updated goal data
          // This isn't strictly necessary here if _checkAndResetDailyStatus only uses prefs,
          // but good if any logic depended on fetched skillGoalData for daily status.
          // For now, the original logic is preserved.
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error fetching goal: $e';
        });
      }
    }
  }

  Future<bool> _performAndUpdateGoal(int rate, String email, String id) async {
    if (!mounted) return false;
    setState(() {
      _isLoadingCompletionAction = true;
      errorMessage = null; // Clear previous action errors
    });

    try {
      final updated = await _journeyService.updateGoal(rate, email, id);
      if (mounted) {
        if (!updated) {
          setState(() {
            errorMessage = 'Failed to update goal progress.';
            _isLoadingCompletionAction = false;
          });
          return false;
        } else {
          // Crucial: Re-fetch goal data to get the latest state including completionRateGoal
          await fetchGoal(email, id);
          // _isLoadingCompletionAction will be set to false by the calling method AFTER other state changes
          return true;
        }
      }
      return false; // Should not be reached if mounted check is robust
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompletionAction = false;
          errorMessage = 'Error updating goal progress: $e';
        });
      }
      return false;
    }
  }

  Future<void> _handleDailyCompletion() async {
    if (skillGoalData == null || _hasCompletedTaskForToday || _isLoadingCompletionAction) return;

    int currentRate = skillGoalData!["completionRateGoal"] ?? 0;
    int totalValue = skillGoalData!["value"] ?? 0; // Target value

    if (currentRate >= totalValue) return; // Already fully achieved

    int newRate = currentRate + 1;
    bool success = await _performAndUpdateGoal(newRate, widget.email, widget.goalData["goalId"]);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getPrefsKey(), _getTodayDateString());
      setState(() {
        _hasCompletedTaskForToday = true;
        _isLoadingCompletionAction = false; // Action complete
        // skillGoalData would have been updated by fetchGoal inside _performAndUpdateGoal
      });
    } else if (mounted) {
      // Error message would have been set by _performAndUpdateGoal.
      // Ensure loading state is reset if not already.
      if (_isLoadingCompletionAction) {
        setState(() { _isLoadingCompletionAction = false; });
      }
    }
  }

  Future<void> _handleRestartGoal() async {
    if (skillGoalData == null || _isLoadingCompletionAction) return;

    // Reset completion rate to 0
    bool success = await _performAndUpdateGoal(0, widget.email, widget.goalData["goalId"]);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getPrefsKey()); // Clear the daily completion marker for the new cycle
      setState(() {
        _hasCompletedTaskForToday = false; // Reset daily completion status
        _isLoadingCompletionAction = false; // Action complete
        // skillGoalData would have been updated by fetchGoal inside _performAndUpdateGoal
      });
    } else if (mounted) {
      if (_isLoadingCompletionAction) {
        setState(() { _isLoadingCompletionAction = false; });
      }
    }
  }

  // This function is replicated as per original, though not directly called by UI buttons shown.
  // If it were to be called, skillTrackId would need to be sourced, e.g. from widget.goalData["skillTrackId"]
  Future<void> completeGoal(String email, String id, String skillLevelId,
      String skillId, String skillTrackId) async {
    if (!mounted) return;
    setState(() {
      isLoading = true; // Using main isLoading flag, consider a specific one if needed
      errorMessage = null;
    });

    try {
      final updated = await _journeyService.updateGoalCompletion(
          email, id, skillLevelId, skillId, skillTrackId);

      if (mounted) {
        setState(() {
          isLoading = false;
          if (updated) {
            // Navigate back to JourneyScreen or a success screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const JourneyScreen()),
                  (Route<dynamic> route) => false, // Remove all previous routes
            );
          } else {
            errorMessage = 'Failed to mark goal as fully completed.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error marking goal as fully completed: $e';
        });
      }
    }
  }


  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      } else if (hexColor.length == 8) {
        return Color(int.parse('0x$hexColor'));
      }
    } catch (e) {
      // print('Error parsing color: $e');
    }
    return Colors.blue; // Default color if parsing fails or invalid format
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentGoalData = skillGoalData ?? widget.goalData; // Fallback to initial data for display if fetch is pending or failed

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorFromString(widget.skill.color),
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.05),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (!_isLoadingCompletionAction) {
                Navigator.pop(context);
              }
            }
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: colorFromString(widget.skill.color),
            width: double.infinity,
            height: double.infinity,
          ),
          if (isLoading && skillGoalData == null) // Show loader only if skillGoalData is not yet available
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (errorMessage != null && skillGoalData == null) // Show error if fetch failed and no data
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          // Use currentGoalData (fetched or initial) for rendering the main content
          // This allows the UI to show something even if the fetch is in progress, using initial widget.goalData
          else if (currentGoalData["title"] == null) // Check if essential data is missing
              const Center(
                child: Text(
                  'Goal data is incomplete or unavailable.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          SvgPicture.network(
                            widget.skill.iconUrl,
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) => const CircularProgressIndicator(strokeWidth: 2, color: Colors.white54,),
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.error_outline, color: Colors.white54, size: screenWidth * 0.2),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            currentGoalData["title"] ?? "Goal Title",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              currentGoalData["description"] ?? "No description provided.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // Use skillGoalData for dynamic parts if available, otherwise initial
                          "Do it ${skillGoalData?["value"] ?? widget.goalData["value"] ?? 0} times to succeed",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Progress indicators should use the most up-to-date data (skillGoalData)
                        if ((skillGoalData?["value"] ?? widget.goalData["value"] ?? 0) > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                skillGoalData?["value"] ?? widget.goalData["value"] ?? 0, (index) {
                              int currentCompletionRate = skillGoalData?["completionRateGoal"] ?? widget.goalData["completionRateGoal"] ?? 0;
                              bool isColored = index < currentCompletionRate;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: TweenAnimationBuilder<Color?>(
                                  tween: ColorTween(
                                    begin: isColored ? Colors.grey.shade400 : Colors.grey.shade400, // Start grey
                                    end: isColored ? Colors.green : Colors.grey.shade400,
                                  ),
                                  duration: const Duration(milliseconds: 400),
                                  builder: (BuildContext context, Color? color, Widget? child) {
                                    return Icon(
                                      Icons.check_circle,
                                      color: color,
                                      size: screenWidth * 0.075,
                                    );
                                  },
                                ),
                              );
                            }),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "No target repetitions set or goal value is zero.",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Display error from actions (like update failed)
                        if (errorMessage != null && !isLoading && !_isLoadingCompletionAction && skillGoalData != null) // Show only if not initial loading error
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        _buildCompletionButtonOrMessage(screenWidth),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildCompletionButtonOrMessage(double screenWidth) {
    // Always use skillGoalData for button logic as it reflects the latest fetched state
    // If skillGoalData is null (e.g., initial load or fetch error), show a loading or error state.
    if (isLoading && skillGoalData == null) { // If still loading initial data
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3,)), // Smaller loader for this section
      );
    }
    if (skillGoalData == null) { // If data fetching failed or not available
      return Text(
        "Goal information unavailable. Cannot determine completion status.",
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.red.shade700),
        textAlign: TextAlign.center,
      );
    }

    int currentRate = skillGoalData!["completionRateGoal"] ?? 0;
    int totalValue = skillGoalData!["value"] ?? 0;

    if (totalValue <= 0) {
      return Text(
        "Goal target not set properly (value is zero or less).",
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.orange.shade800),
        textAlign: TextAlign.center,
      );
    }

    if (_isLoadingCompletionAction) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3,)),
      );
    }

    if (currentRate >= totalValue) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Congratulations! Goal Fully Achieved!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.green.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
              textStyle: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
            ).copyWith(
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: _isLoadingCompletionAction ? null : _handleRestartGoal, // Disable if another action is processing
            child: const Text("Restart Goal"),
          ),
        ],
      );
    } else if (_hasCompletedTaskForToday) {
      return Text(
        "Today's progress recorded. Well done!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.green.shade700, fontWeight: FontWeight.bold),
      );
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFromString(widget.skill.color),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 12),
          textStyle: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
        ).copyWith(
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
        onPressed: _isLoadingCompletionAction ? null : _handleDailyCompletion, // Disable if another action is processing
        child: const Text("I've done this today"),
      );
    }
  }
}