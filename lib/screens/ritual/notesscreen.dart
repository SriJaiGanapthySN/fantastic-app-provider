import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importing the intl package for date formatting

// ignore: must_be_immutable
class Notesscreen extends StatefulWidget {
  final String email;
  final String taskID;
  final String title;
  final String items;
  String timestamp; // Change timestamp to be mutable

  Notesscreen({
    super.key,
    required this.email,
    required this.taskID,
    required this.title,
    required this.items,
    required this.timestamp,
  });

  @override
  State<Notesscreen> createState() => _NotesscreenState();
}

class _NotesscreenState extends State<Notesscreen> {
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;
  bool showIcons = false;

  final int maxLength = 8000; // Maximum character limit

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
        text: widget.items.isNotEmpty ? widget.items : '');
    textFieldFocusNode = FocusNode();

    // Automatically focus the text field if text is present
    if (widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        textFieldFocusNode.requestFocus();
      });
    }

    textController.addListener(() {
      // Update the visibility of icons based on the presence of text
      setState(() {
        showIcons = textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    textController.dispose(); // Clean up the controller
    textFieldFocusNode.dispose(); // Clean up the focus node
    super.dispose();
  }

  void _saveNote() async {
    // Get current timestamp
    String formattedTimestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Save the current timestamp
    setState(() {
      widget.timestamp = formattedTimestamp; // Update the timestamp field
    });

    await TaskServices().updateTaskNotes(
      id: widget.taskID,
      mail: widget.email,
      title: widget.title,
      items: textController.text,
      timestamp: formattedTimestamp,
    );

    // Implement any other save functionality here (e.g., saving to database)

    // Show a success message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Note saved!')),
    // );
    Navigator.pop(context);
  }

  void _deleteNote() async {
    // Call the service to delete the note
    await TaskServices().deleteTaskNote(
      taskID: widget.taskID,
      mail: widget.email,
    );

    // Clear the text field
    textController.clear();

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted!')),
    );

    // Optionally, navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SizedBox.shrink(), // Remove default title from app bar
        actions: [
          // Row to center the character count and place icons to the right
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the count
              children: [
                // Character count displayed in the app bar, centered
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${textController.text.length}/$maxLength',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Same size as the icon
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Display Save and Delete icons on the right if text is present
          if (showIcons) ...[
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveNote, // Trigger save functionality
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteNote,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title displayed above the text editor, centered
              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                  height: 16), // Add some space between title and text field

              // Text Editor (TextField)
              TextField(
                controller: textController,
                focusNode: textFieldFocusNode,
                cursorColor: Colors.red,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                maxLines: 25, // Makes the input box bigger
                maxLength: maxLength, // Limit the text to 8000 characters
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 0, 0, 0),
                  hintText: "What's on your mind?",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterText: "", // Hide the default counter
                ),
                onChanged: (value) {
                  setState(() {}); // Update the character count
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
