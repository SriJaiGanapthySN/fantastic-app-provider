import 'package:fab/models/skill.dart';
import 'package:fab/models/skillTrack.dart';
import 'package:fab/screens/journeys/journeysecondlevel.dart';
import 'package:fab/services/journey_service.dart';
import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart';
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
      // Await the result from getSkillGoal
      skillGoalData = await _journeyService.getSkillGoal(email, id);

      // Refresh the UI after data is fetched
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
      // Await the result from getSkillGoal
      final upddated = await _journeyService.updateGoal(rate, email, id);

      // Refresh the UI after data is fetched
      if (upddated) {
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
      // Await the result from getSkillGoal
      final upddated = await _journeyService.updateGoalCompletion(
          email, id, skillLevelId, skillId, skillTrackId);

      // Refresh the UI after data is fetched
      if (upddated) {
        print("COMPLETED!");
        // Navigator.pushReplacement(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (context) => Journeysecondlevel(
        //                       skill: widget.skill,
        //                       email: email,
        //                       skilltrack: widget.skilltrack,
        //                     ),
        //                   ),
        //                 );

        int count = 0; // Counter to track popped routes
        Navigator.popUntil(
          context,
          (route) {
            count++;
            return count > 1; // Stop popping after 2 routes
          },
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Journeysecondlevel(
              skill: widget.skill,
              email: email,
              skilltrack: widget.skilltrack,
            ),
          ),
        );

        // await fetchGoal(email, id);
      } else {
        print("Not Completing");
      }
    } catch (e) {
      print('Error fetching goal: $e');
    }
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
    // Fetch screen size for dynamic font and spacing
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: skillGoalData == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
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
                    // Centered Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 50),
                        SvgPicture.network(
                          widget.skill.iconUrl,
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 24),
                        Text(
                          skillGoalData?["title"] ?? "Loading...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.09,
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            skillGoalData?["description"] ??
                                "Loading description...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Center-aligned "Do it _ times" box at the bottom
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(),
                      ),
                      padding: EdgeInsets.all(16),
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
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                skillGoalData?["value"] ?? 0, (index) {
                              // Check if the completionRateGoal is greater than 0
                              int completionRateGoal =
                                  skillGoalData?["completionRateGoal"] ?? 0;
                              bool isColored = index < completionRateGoal;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.check_circle,
                                  color: isColored
                                      ? colorFromString(widget.skill.color)
                                      : Colors
                                          .grey, // Gray if the goal isn't met
                                  size: screenWidth * 0.1,
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              int completionRateGoal =
                                  skillGoalData?["completionRateGoal"] ?? 0;
                              int value = skillGoalData?["value"] ?? 0;

                              return (completionRateGoal < value)
                                  ? ElevatedButton(
                                      onPressed: () {
                                        completionRateGoal =
                                            completionRateGoal + 1;
                                        updateGoal(
                                            completionRateGoal,
                                            widget.email,
                                            widget.goalData["goalId"]);
                                        if (completionRateGoal == value) {
                                          completeGoal(
                                              widget.email,
                                              widget.goalData["goalId"],
                                              widget.goalData["objectId"],
                                              widget.skill.objectId,
                                              widget.skilltrack.objectId);
                                        }

                                        // Add action here, such as marking goal as complete
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.green, // Green button
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 32.0, vertical: 12.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'I have done this today!',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Completed",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                            },
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
