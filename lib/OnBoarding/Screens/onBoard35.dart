import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../States/StateNotifiers.dart';
import 'finalScreen.dart';
import 'onBoard26.dart';
import 'onBoard36.dart';

class Onboard35 extends ConsumerStatefulWidget {
  const Onboard35({super.key});

  @override
  _OnBoard35 createState() => _OnBoard35();
}

class _OnBoard35 extends ConsumerState<Onboard35> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea( // Added SafeArea to avoid going behind status bar
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cross Icon at Top Left
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingCompletedScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What should we call you?",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "MY FULL NAME IS",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "FULL NAME",
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
                      ),
                      SizedBox(height: 30),
                      Text(
                        "By using your full name, you help our fun and supportive community thrive. Our Fabulous community embraces positivity based on trust and encouragement. We're in this together.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled
                              ? () {
                            ref.read(selectedSleepProvider.notifier).addPersonalDetails(_nameController.text);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OnBoard36()),
                            );
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              Icon(Icons.arrow_right_alt_rounded, color: Colors.indigo),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
