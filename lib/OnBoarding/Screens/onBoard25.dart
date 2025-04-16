import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../States/StateNotifiers.dart';
import 'onBoard26.dart';

// Ensure you are using the correct imports for Riverpod
class Onboard25 extends ConsumerStatefulWidget {
  const Onboard25({super.key});

  @override
  _OnBoard25 createState() => _OnBoard25();
}

class _OnBoard25 extends ConsumerState<Onboard25> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();  // FocusNode to manage focus
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isButtonEnabled = _nameController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();  // Dispose of the FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo, // Blue background
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Save Your Progress",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "My first name is...",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              focusNode: _focusNode,  // Attach FocusNode here
              autofocus: true,  // Optional: Focuses on the field automatically when the page loads
              decoration: InputDecoration(
                hintText: "Enter your name",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,  // Makes the entered text bold
              ),
              cursorColor: Colors.white,  // Sets the cursor color to white
              cursorWidth: 3.0,  // Makes the cursor thicker
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  // Accessing the StateNotifier via ref.read()
                  ref.read(selectedSleepProvider.notifier).addPersonalDetails(_nameController.text);

                  // Navigate to the next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Onboard26()), // Replace `NextPage` with your target page
                  );
                }
                    : null, // Disable when no text
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    Icon(Icons.arrow_right_alt_rounded, color: Colors.indigo,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
