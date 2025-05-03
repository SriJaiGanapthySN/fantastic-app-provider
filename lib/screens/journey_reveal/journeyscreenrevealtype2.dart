import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  State<Journeyscreenrevealtype2> createState() => _Journeyscreenrevealtype2();
}

class _Journeyscreenrevealtype2 extends State<Journeyscreenrevealtype2> {
  final String title = "Goal";
  final JourneyService _journeyService = JourneyService();
  Map<String, dynamic>? skillGoalData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchGoal(widget.email, widget.goalData["goalId"]);
  }

  Future<void> fetchGoal(String email, String id) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      skillGoalData = await _journeyService.getSkillGoal(email, id);
      
      setState(() {
        isLoading = false;
        if (skillGoalData == null) {
          errorMessage = 'No goal data found';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching goal: $e';
      });
    }
  }

  Future<void> updateGoal(int rate, String email, String id) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final updated = await _journeyService.updateGoal(rate, email, id);
      
      setState(() {
        isLoading = false;
        if (!updated) {
          errorMessage = 'Failed to update goal';
        } else {
          fetchGoal(email, id);
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error updating goal: $e';
      });
    }
  }

  Future<void> completeGoal(String email, String id, String skillLevelId,
      String skillId, String skillTrackId) async {
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: colorFromString(widget.skill.color),
            width: double.infinity,
            height: double.infinity,
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (skillGoalData == null)
            const Center(
              child: Text(
                'No goal data available',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),
                    SvgPicture.network(
                      widget.skill.iconUrl,
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      skillGoalData!["title"] ?? "No Title",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.09,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        skillGoalData!["description"] ?? "No Description",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            skillGoalData!["value"] ?? 0, (index) {
                          int completionRateGoal =
                              skillGoalData!["completionRateGoal"] ?? 0;
                          bool isColored = index < completionRateGoal;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.check_circle,
                              color: isColored
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
