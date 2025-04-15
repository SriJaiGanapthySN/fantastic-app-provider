import 'package:fantastic_app_riverpod/screens/ritual/notesscreen.dart';
import 'package:flutter/material.dart';

class GeneralComponentScreen extends StatelessWidget {
  final String email;
  final String taskID;
  final String title;
  final String items;
  final String timestamp;

  const GeneralComponentScreen({
    super.key,
    required this.email,
    required this.taskID,
    required this.title,
    required this.items,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to another page when the text is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Notesscreen(
                      email: email,
                      taskID: taskID,
                      title: title,
                      items: items,
                      timestamp: timestamp,
                    ),
                  ),
                );
              },
              child: Text(
                items,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              timestamp,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
