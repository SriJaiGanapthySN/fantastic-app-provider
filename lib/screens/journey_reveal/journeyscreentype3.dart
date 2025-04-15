import 'package:fab/models/skill.dart';
import 'package:fab/models/skillTrack.dart';
import 'package:fab/screens/journeys/journeysecondlevel.dart';
import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class Journeyscreentype3 extends StatelessWidget {
  final Map motivatorData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  Journeyscreentype3({
    super.key,
    required this.motivatorData,
    required this.skill,
    required this.email,
    required this.skilltrack,
  });

  Future<String> fetchContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body; // Return the raw HTML content
      } else {
        return 'Failed to load content';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  final JourneyService _journeyService = JourneyService();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        actions: [],
      ),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Headline Image
                Image.network(
                  motivatorData['headlineImageUrl'],
                  fit: BoxFit.cover,
                  height: screenHeight * 0.25, // Responsive height
                  width: screenWidth,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Headline Text (Left-Aligned)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    motivatorData['contentTitle'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.07, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Content Section (HTML fetched and rendered)
                FutureBuilder<String>(
                  future: fetchContent(motivatorData['contentUrl']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: Html(
                          data: snapshot.data ?? '<p>No content available</p>',
                          style: {
                            "html": Style(
                              fontSize: FontSize(
                                  screenWidth * 0.045), // Responsive text size
                              lineHeight:
                                  LineHeight(1.6), // Improve line spacing
                              color: Colors.black87, // Text color
                            ),
                            "p": Style(
                              fontSize: FontSize(screenWidth * 0.045),
                              color: Colors.black87,
                              textAlign: TextAlign.justify, // Align text
                            ),
                            "ul": Style(
                              padding: HtmlPaddings.only(
                                  left:
                                      screenWidth * 0.04), // Indent list items
                            ),
                            "li": Style(
                              fontSize: FontSize(screenWidth * 0.045),
                              color: Colors.black87,
                            ),
                          },
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                    height: screenHeight * 0.1), // Add spacing at the bottom
              ],
            ),
          ),
          // Fixed Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 10, // Set elevation for shadow
              shadowColor:
                  Colors.black.withOpacity(0.6), // Shadow color and opacity
              child: Container(
                color:
                    Colors.grey.shade300, // Grey background for the bottom bar
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight *
                      0.02, // Adjust vertical padding for responsiveness
                  horizontal: screenWidth * 0.04, // Adjust horizontal padding
                ),
                child: Container(
                  width: double.infinity, // Stretch button from left to right
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.04, // Same padding as other button
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Update the isCompleted value
                      motivatorData["isCompleted"] = true;

                      // Call the updateOneTime function from the service
                      bool isUpdated = await _journeyService.updateMotivator(
                          true,
                          motivatorData["objectId"],
                          email,
                          skill.objectId,
                          skilltrack.objectId);

                      if (isUpdated) {
                        // If the update is successful, navigate to the next screen
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Journeysecondlevel(
                        //       skill: skill,
                        //       email: email,
                        //       skilltrack: skilltrack!,
                        //     ),
                        //   ),
                        // );

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
                              skill: skill,
                              email: email,
                              skilltrack: skilltrack,
                            ),
                          ),
                        );
                      } else {
                        // Handle failure case if needed
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Failed to update task. Please try again.'),
                        ));
                      }
                      // Define the button action here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 13, 173, 32), // Button color
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight *
                              0.02), // Increased vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      elevation: 10, // Add elevation for shadow effect
                      shadowColor:
                          Colors.black.withOpacity(0.8), // Shadow color
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the content horizontally
                      children: [
                        Icon(
                          Icons.arrow_forward, // Icon for the button
                          color: Colors.white,
                          size: screenWidth * 0.06, // Responsive icon size
                        ),
                        SizedBox(
                            width: screenWidth *
                                0.02), // Space between icon and text
                        Text(
                          'Done! What Next', // Button label
                          style: TextStyle(
                            fontSize:
                                screenWidth * 0.05, // Responsive font size
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
