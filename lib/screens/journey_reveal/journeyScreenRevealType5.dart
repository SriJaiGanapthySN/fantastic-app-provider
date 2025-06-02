import 'package:flutter/material.dart';

// Example data map (as provided in the question)
// final Map<String, dynamic> createdDataMap = {
//   'createdAt': DateTime.now().millisecondsSinceEpoch,
//   'description': 'This is a detailed description of the goal or habit. It explains the purpose, benefits, and any specific instructions related to achieving this. The text can be quite long to test responsiveness and readability. We should ensure it wraps correctly and looks good on various screen sizes.',
//   'objectId': 'unique_object_id_123',
//   'removePreviousGoalHabits': false,
//   'ritualType': 'MORNING',
//   'skillTrackId': 'skill_track_abc',
//   'title': 'My Awesome Goal Title',
//   'type': 'GOAL',
//   'updatedAt': DateTime.now().millisecondsSinceEpoch,
//   'value': 10,
//   'habitIds': ['habit_1', 'habit_2', 'habit_3'],
// };

class DataDisplayScreen extends StatelessWidget {
  final String email;
  final Map<String, dynamic> dataMap;

  const DataDisplayScreen({
    Key? key,
    required this.email,
    required this.dataMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely extract title and description
    final String title = dataMap['title']?.toString() ?? "No Title Provided";
    final String description =
        dataMap['description']?.toString() ?? "No Description Provided";

    return Scaffold(
      // AppBar with a back arrow and a simple title
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white), // Modern back arrow
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Details', // Or you could use dataMap['title'] here if it's short
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple, // A professional color
        elevation: 2.0, // Subtle shadow
        centerTitle: true,
      ),
      // Body with a gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade50,
              Colors.purple.shade100,
              Colors.pink.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
              children: <Widget>[
                // Optional: Display email if needed (not explicitly requested for main display)
                // Text(
                //   'User: $email',
                //   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                // ),
                // SizedBox(height: 10),

                // Card to display title and description
                Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Card takes minimum space
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Divider(color: Colors.deepPurple.shade100),
                        SizedBox(height: 15.0),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black87,
                            height: 1.5, // Line height for readability
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Spacer to push the button to the bottom
                const Spacer(),
                // Elevated Button at the bottom
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Button color
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded button
                    ),
                    elevation: 3.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back
                  },
                  child: const Text(
                    'Done! What\'s next?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

