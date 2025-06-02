import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../journey_screen.dart';
import '../../models/skill.dart';
import '../../models/skillTrack.dart';
import '../../services/journey_service.dart';

class Journeyscreenrevealtype2 extends StatefulWidget {
  final Map goalData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  const Journeyscreenrevealtype2({
    super.key,
    required this.goalData,
    required this.skill,
    required this.email,
    required this.skilltrack,
  });

  @override
  State<Journeyscreenrevealtype2> createState() => _Journeyscreenrevealtype2State();
}

class _Journeyscreenrevealtype2State extends State<Journeyscreenrevealtype2>
    with WidgetsBindingObserver {
  final String title = "Goal";
  final JourneyService _journeyService = JourneyService();
  Map<String, dynamic>? skillGoalData;
  bool isLoading = true;
  String? errorMessage;

  bool _hasCompletedTaskForToday = false;
  bool _isLoadingCompletionAction = false; // Used for "Complete Today" and "Restart"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      if (!isLoading) {
        _checkAndResetDailyStatus();
      }
    }
  }

  Future<void> _loadDailyStatusAndUpdateGoal() async {
    await _checkAndResetDailyStatus();
    await fetchGoal(widget.email, widget.goalData["goalId"]);
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

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
          if (lastCompletionDateStr != null) {
            // No need to remove here, only on successful restart or if app logic dictates
            // prefs.remove(_getPrefsKey());
          }
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
      final data = await _journeyService.getSkillGoal(email, id);
      if (mounted) {
        setState(() {
          skillGoalData = data;
          isLoading = false;
          if (skillGoalData == null) {
            errorMessage = 'No goal data found';
          }
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
            errorMessage = 'Failed to update goal';
            _isLoadingCompletionAction = false;
          });
          return false;
        } else {
          await fetchGoal(email, id); // Refreshes skillGoalData
          // _isLoadingCompletionAction will be set to false by the calling method AFTER other state changes
          return true;
        }
      }
      return false;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompletionAction = false;
          errorMessage = 'Error updating goal: $e';
        });
      }
      return false;
    }
  }

  Future<void> _handleDailyCompletion() async {
    if (skillGoalData == null || _hasCompletedTaskForToday) return;

    int currentRate = skillGoalData!["completionRateGoal"] ?? 0;
    int totalValue = skillGoalData!["value"] ?? 0;

    if (currentRate >= totalValue) return;

    // setState for _isLoadingCompletionAction is handled by _performAndUpdateGoal
    int newRate = currentRate + 1;
    bool success = await _performAndUpdateGoal(newRate, widget.email, widget.goalData["goalId"]);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getPrefsKey(), _getTodayDateString());
      setState(() {
        _hasCompletedTaskForToday = true;
        _isLoadingCompletionAction = false; // Action complete
      });
    } else if (mounted) {
      // Error message would have been set by _performAndUpdateGoal, it also sets _isLoadingCompletionAction = false on error
      // So, we only need to ensure it's false if somehow not set by _performAndUpdateGoal's error path
      if (_isLoadingCompletionAction) {
        setState(() { _isLoadingCompletionAction = false; });
      }
    }
  }

  Future<void> _handleRestartGoal() async {
    if (skillGoalData == null) return;

    // setState for _isLoadingCompletionAction is handled by _performAndUpdateGoal
    bool success = await _performAndUpdateGoal(0, widget.email, widget.goalData["goalId"]);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getPrefsKey()); // Clear the daily completion marker for the new cycle
      setState(() {
        _hasCompletedTaskForToday = false; // Reset daily completion status
        _isLoadingCompletionAction = false; // Action complete
      });
    } else if (mounted) {
      // Error message would have been set by _performAndUpdateGoal, it also sets _isLoadingCompletionAction = false on error
      if (_isLoadingCompletionAction) {
        setState(() { _isLoadingCompletionAction = false; });
      }
    }
  }

  Future<void> completeGoal(String email, String id, String skillLevelId,
      String skillId, String skillTrackId) async {
    // ... (your existing completeGoal logic - unchanged)
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final updated = await _journeyService.updateGoalCompletion(
          email, id, skillLevelId, skillId, skillTrackId);

      setState(() {
        isLoading = false;
        if (updated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const JourneyScreen(),
            ),
          );
        } else {
          errorMessage = 'Failed to complete goal';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error completing goal: $e';
      });
    }
  }

  Color colorFromString(String colorString) {
    // ... (your existing colorFromString logic - unchanged)
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {
      print('Error parsing color: $e');
    }
    return Colors.blue; // Default color if parsing fails
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
              if (!_isLoadingCompletionAction) { // Prevent pop while action is in progress
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
          if (isLoading && skillGoalData == null)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (errorMessage != null && skillGoalData == null)
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
          else if (skillGoalData == null)
              const Center(
                child: Text(
                  'No goal data available to display.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
                          ),
                          const SizedBox(height: 24),
                          Text(
                            skillGoalData!["title"] ?? "No Title",
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
                              skillGoalData!["description"] ?? "No Description",
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
                          "Do it ${skillGoalData!["value"] ?? 0} times this week to succeed",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (skillGoalData!["value"] != null && skillGoalData!["value"] > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                skillGoalData!["value"] ?? 0, (index) {
                              int currentCompletionRate = skillGoalData!["completionRateGoal"] ?? 0;
                              bool isColored = index < currentCompletionRate;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: TweenAnimationBuilder<Color?>(
                                  tween: ColorTween(
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
                              "No target repetitions set.",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Display error from actions here, above the buttons/messages for clarity
                        if (errorMessage != null && !isLoading && !_isLoadingCompletionAction)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0), // Space before button
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
    if (skillGoalData == null) return const SizedBox.shrink();

    int currentRate = skillGoalData!["completionRateGoal"] ?? 0;
    int totalValue = skillGoalData!["value"] ?? 0;

    if (totalValue <= 0) {
      return Text(
        "Goal target not set properly.",
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.orange),
        textAlign: TextAlign.center,
      );
    }

    if (_isLoadingCompletionAction) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0), // Give some space for the loader
        child: CircularProgressIndicator(),
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
              backgroundColor: Colors.blueGrey, // A different color for restart
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
              textStyle: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
            ).copyWith(
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: _handleRestartGoal,
            child: const Text("Would you like to restart?"),
          ),
        ],
      );
    } else if (_hasCompletedTaskForToday) {
      return Text(
        "Today's Goal Completed. Well done!!",
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
        onPressed: _handleDailyCompletion,
        child: const Text("I have done this Today"),
      );
    }
  }
}