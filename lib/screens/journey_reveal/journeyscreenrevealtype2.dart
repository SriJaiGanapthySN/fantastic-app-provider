import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';
import 'package:fantastic_app_riverpod/services/journey_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Journeyscreenrevealtype2 extends StatefulWidget {
  final Map goalData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  const Journeyscreenrevealtype2(
      {super.key,
      required this.goalData,
      required this.skill,
      required this.email,
      required this.skilltrack});

  @override
  State<Journeyscreenrevealtype2> createState() => _Journeyscreenrevealtype2();
}

class _Journeyscreenrevealtype2 extends State<Journeyscreenrevealtype2> {
  final String title = "Goal";
  final JourneyService _journeyService = JourneyService();
  Map<String, dynamic>? skillGoalData;

  @override
  void initState() {
    super.initState();
    fetchGoal(widget.email, widget.goalData["goalId"]);
  }

  Future<void> fetchGoal(String email, String id) async {
    try {
      skillGoalData = await _journeyService.getSkillGoal(email, id);
      setState(() {
        if (skillGoalData != null) {
          print(skillGoalData);
        } else {
          print('No goal data found for email: $email and id: $id');
        }
      });
    } catch (e) {
      print('Error fetching goal: $e');
    }
  }

  Future<void> updateGoal(int rate, String email, String id) async {
    try {
      final updated = await _journeyService.updateGoal(rate, email, id);
      if (updated) {
        print("Updated!");
        await fetchGoal(email, id);
      } else {
        print("Not Updating");
      }
    } catch (e) {
      print('Error fetching goal: $e');
    }
  }

  Future<void> completeGoal(String email, String id, String skillLevelId,
      String skillId, String skillTrackId) async {
    try {
      final updated = await _journeyService.updateGoalCompletion(
          email, id, skillLevelId, skillId, skillTrackId);

      if (updated) {
        print("COMPLETED!");
        int count = 0;
        Navigator.popUntil(
          context,
          (route) {
            count++;
            return count > 1;
          },
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const JourneyRoadmapScreen(),
          ),
        );
      } else {
        print("Not Completing");
      }
    } catch (e) {
      print('Error fetching goal: $e');
    }
  }

  Color colorFromString(String colorString) {
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('0xFF$hexColor'));
    } else {
      throw FormatException('Invalid color string format');
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: skillGoalData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  color: colorFromString(widget.skill.color),
                  width: double.infinity,
                  height: double.infinity,
                ),
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
                        ),
                        const SizedBox(height: 24),
                        Text(
                          skillGoalData?["title"] ?? "Loading...",
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
                            skillGoalData?["description"] ?? "Loading description...",
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
                        borderRadius: BorderRadius.vertical(),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Do it ${skillGoalData?["value"] ?? 0} times this week to succeed",
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
                                skillGoalData?["value"] ?? 0, (index) {
                              int completionRateGoal =
                                  skillGoalData?["completionRateGoal"] ?? 0;
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
