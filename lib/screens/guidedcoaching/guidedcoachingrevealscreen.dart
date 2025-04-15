import 'package:flutter/material.dart';

class Guidedcoachingrevealscreen extends StatefulWidget {
  const Guidedcoachingrevealscreen({super.key});

  @override
  _Guidedcoachingrevealscreen createState() {
    return _Guidedcoachingrevealscreen();
  }
}

class _Guidedcoachingrevealscreen extends State<Guidedcoachingrevealscreen> {
  int currentStep = 0;
  bool isPlaying = false;

  final List<Map<String, String>> exercises = [
    {
      "name": "Jumping Jacks",
      "time": "30s",
      "image": "assets/images/login.jpg"
    },
    {"name": "Breathe", "time": "10s", "image": "assets/images/login.jpg"},
    {"name": "Push-ups", "time": "20s", "image": "assets/images/login.jpg"},
  ];

  void nextStep() {
    setState(() {
      if (currentStep < exercises.length - 1) {
        currentStep++;
      }
    });
  }

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Safe Area Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                // Title
                if (isPlaying)
                  const Padding(
                    padding: EdgeInsets.only(left: 40, top: 20),
                    child: Text(
                      "7-MIN\nWorkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Play/Pause Button
                Expanded(
                  child: Center(
                    child: CircleAvatar(
                      radius: isPlaying ? 50 : 40,
                      backgroundColor: isPlaying
                          ? const Color.fromARGB(255, 31, 203, 203)
                          : Colors.pink,
                      child: IconButton(
                        onPressed: togglePlayPause,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: isPlaying ? 50 : 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // Exercise Cards
                Stack(
                  alignment: Alignment.center,
                  children: exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;

                    final positionOffset = (index - currentStep) * 30.0;

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      bottom: positionOffset + 50,
                      left: positionOffset.abs() + 20,
                      right: positionOffset.abs() + 20,
                      child: GestureDetector(
                        onTap: () {
                          if (currentStep == index) {
                            nextStep();
                          }
                        },
                        child: Opacity(
                          opacity: index == currentStep ? 1.0 : 0.5,
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: AssetImage(exercise['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise['name']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        exercise['time']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
