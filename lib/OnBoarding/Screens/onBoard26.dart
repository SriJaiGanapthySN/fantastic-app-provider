import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';  // For TextInputFormatter
import '../States/StateNotifiers.dart';
import 'onBoard27.dart';

class Onboard26 extends ConsumerStatefulWidget {
  const Onboard26({super.key});

  @override
  _OnBoard25 createState() => _OnBoard25();
}

class _OnBoard25 extends ConsumerState<Onboard26> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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
    _focusNode.dispose();
    super.dispose();
  }

  // Method to validate if the entered text is a valid number between 0 and 120
  bool _isValidAge(String input) {
    final age = int.tryParse(input);
    return age != null && age >= 0 && age <= 120;
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
              "What is your age?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Enter your age",
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
                fontWeight: FontWeight.bold,
              ),
              cursorColor: Colors.white,
              cursorWidth: 3.0,
              inputFormatters: [
                // Restrict input to only digits
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  String input = _nameController.text;

                  // Validate if the input is a valid age between 0 and 120
                  if (!_isValidAge(input)) {
                    // Show Snackbar for invalid input
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please enter a valid age between 0 and 120."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Accessing the StateNotifier via ref.read()
                    ref.read(selectedSleepProvider.notifier).addPersonalDetails(input);

                    // Navigate to the next page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => OnBoard27()), // Replace `NextPage` with your target page
                    );
                  }
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
