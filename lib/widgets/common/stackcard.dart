import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import 'package:fantastic_app_riverpod/services/guided_activities.dart';
import 'package:flutter/material.dart';

class VerticalStackedCardScreen extends StatefulWidget {
  final Map<String, dynamic> training;
  const VerticalStackedCardScreen({super.key, required this.training});

  @override
  State<VerticalStackedCardScreen> createState() =>
      _VerticalStackedCardScreenState();
}

class _VerticalStackedCardScreenState extends State<VerticalStackedCardScreen> {
  bool isMuted = false;
  final GuidedActivities _guidedActivities = GuidedActivities();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int currentCardIndex = 0;
  bool isPlaying = false;
  double progress = 1.0;
  Timer? timer;
  double remainingSeconds = 0; // Tracks remaining time
  double totalDuration = 0; // Total duration of the exercise
  List<Map<String, dynamic>> exercises = [];

  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {
      // Default to black if color string is invalid
      return Colors.black;
    }
    throw FormatException('Invalid color string format');
  }

  @override
  void initState() {
    super.initState();
    loadStepData();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void loadStepData() async {
    List<Map<String, dynamic>> steps = await _fetchSteps();
    setState(() {
      exercises = steps; // Update stepData after fetching
    });
    // stepData.add(widget.training);
    exercises.insert(0, widget.training);
  }

  Future<List<Map<String, dynamic>>> _fetchSteps() async {
    return await _guidedActivities.fetchSteps(widget.training["objectId"]);
  }

  void startTimer(double seconds) {
    setState(() {
      if (remainingSeconds == 0) {
        remainingSeconds = seconds; // Initialize remaining time
        totalDuration = seconds; // Store total duration
        progress = 1.0; // Full progress bar
      }
      isPlaying = true;
    });

    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        remainingSeconds -= 0.0975;

        // Update progress correctly
        progress = remainingSeconds / totalDuration;

        if (remainingSeconds <= 0) {
          timer.cancel();
          remainingSeconds = 0;
          progress = 0.0;
          nextCard();
        }
      });
    });
  }

  void _playAudio(String link) {
    _audioPlayer.play(UrlSource(link));
  }

  void _stopAudio() {
    _audioPlayer.stop();
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  void nextCard() {
    setState(() {
      if (currentCardIndex < exercises.length - 1) {
        currentCardIndex++;
        progress = 1.0;
        isPlaying = false;

        // Automatically start the timer for the next card if it has a time
        if (exercises[currentCardIndex].containsKey('duration')) {
          // int seconds = int.parse(exercises[currentCardIndex]['duration']!.replaceAll('s', ''));
          double seconds = exercises[currentCardIndex]['duration'] * 1.0;

          startTimer(seconds);
          _playAudio(exercises[currentCardIndex]["soundUrl"]);
        }
      } else {
        _stopAudio();
        Navigator.pop(context);
      }
    });
  }

  void removeIntroductoryCard() {
    setState(() {
      currentCardIndex++;
    });

    // After incrementing the card index, check if the next card has a timer.
    if (currentCardIndex < exercises.length &&
        exercises[currentCardIndex].containsKey('duration')) {
      // int seconds = int.parse(exercises[currentCardIndex]['duration']!.replaceAll('s', ''));
      double seconds = exercises[currentCardIndex]['duration'] * 1.0;
      startTimer(seconds);
      _playAudio(exercises[currentCardIndex]["soundUrl"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight =
        screenHeight * 0.82; // Increased card height for visibility
    final cardWidth =
        screenWidth * 0.9; // Increased card width for better proportion
    final overlap = 25.0; // Adjusted overlap to 25
    final verticalOffset =
        screenHeight * 0.05; // 5% vertical offset from the top

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            alignment: Alignment.center,
            children: exercises.asMap().entries.toList().reversed.map((entry) {
              final index = entry.key;
              final exercise = entry.value;

              // Show only the top 3 cards
              if (index < currentCardIndex || index > currentCardIndex + 2) {
                return const SizedBox.shrink();
              }

              final positionOffset = (index - currentCardIndex) * overlap;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: positionOffset + verticalOffset, // Shifted 5% down
                left: index == currentCardIndex
                    ? 0
                    : 10 * (index - currentCardIndex).toDouble(),
                right: index == currentCardIndex
                    ? 0
                    : 10 * (index - currentCardIndex).toDouble(),
                child: Opacity(
                  opacity:
                      index < currentCardIndex || index > currentCardIndex + 2
                          ? 0.0
                          : 1.0,
                  child: Transform.translate(
                    offset: Offset(
                        0,
                        index == currentCardIndex
                            ? 0
                            : (index - currentCardIndex) * 20),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: exercise.containsKey('duration')
                                ? NetworkImage(exercise['imageUrl']!)
                                : NetworkImage(exercise['bigImageUrl']!),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Gradient Overlay (optional)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black
                                        .withOpacity(0.6), // Starting color
                                    Colors.transparent, // Ending color
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            if (!exercise.containsKey('duration'))
                              Positioned(
                                right: 20,
                                top: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "5-min",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            // Title on top for the introductory card
                            if (!exercise.containsKey('duration'))
                              Positioned(
                                top: 70,
                                left: 20,
                                right: 80,
                                child: Text(
                                  exercise['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                            // subtitle on top for the introductory card
                            if (!exercise.containsKey('duration'))
                              Positioned(
                                top: 210,
                                left: 25,
                                right: 80,
                                child: Text(
                                  exercise['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                            // Play button on the introductory card
                            if (!exercise.containsKey('duration'))
                              Align(
                                alignment: Alignment
                                    .bottomCenter, // Center horizontally at the bottom
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: cardHeight *
                                          0.15), // Vertical position
                                  child: GestureDetector(
                                    onTap: removeIntroductoryCard,
                                    child: Container(
                                      width: cardWidth / 3.5,
                                      height: cardWidth / 3.5,
                                      decoration: BoxDecoration(
                                        color: colorFromString(
                                            widget.training["color"]),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: cardWidth / 6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Name on bottom-left and time on bottom-right for other cards
                            if (exercise.containsKey('duration'))
                              Positioned(
                                bottom:
                                    10, // Adjusted bottom position to fit better within overlap
                                left: 20,
                                right: 20,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        exercise['text']!,
                                        style: TextStyle(
                                          color: exercise
                                                  .containsKey("isTextWhite")
                                              ? Colors.white
                                              : Colors.grey,
                                          fontSize: 24,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                    ),
                                    Text(
                                      //  exercise['duration']!,
                                      "${exercise['duration']}s",
                                      style: TextStyle(
                                        color:
                                            exercise.containsKey("isTextWhite")
                                                ? Colors.white
                                                : Colors.grey,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            //cross button
                            Positioned(
                              left: 20,
                              top: 20,
                              child: IconButton(
                                onPressed: () {
                                  _stopAudio();
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            //mute button
                            if (exercise.containsKey('duration'))
                              Positioned(
                                right: 20,
                                top: 20,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isMuted = !isMuted; // Toggle mute state
                                    });
                                    if (isMuted) {
                                      _audioPlayer.setVolume(
                                          0); // Set volume to 0 (mute)
                                    } else {
                                      _audioPlayer.setVolume(
                                          1); // Set volume back to normal (unmute)
                                    }
                                  },
                                  icon: Icon(
                                    isMuted
                                        ? Icons.volume_off_outlined
                                        : Icons.volume_up_outlined,
                                    color: Colors.pink,
                                    size: 32,
                                  ),
                                ),
                              ),

                            // Play/Pause Button with Circular Progress for current card
                            if (index == currentCardIndex &&
                                exercise.containsKey('duration'))
                              Stack(children: [
                                Align(
                                  alignment: Alignment
                                      .bottomCenter, // Center horizontally, bottom vertically
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: cardHeight *
                                            0.15), // Adjust vertical position
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!isPlaying) {
                                          if (exercise
                                              .containsKey('duration')) {
                                            double seconds =
                                                exercise['duration'] * 1.0;
                                            startTimer(seconds);
                                            _playAudio(exercise["soundUrl"]);
                                          }
                                        } else {
                                          stopTimer();
                                          _audioPlayer.pause();
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Circular Progress Indicator
                                          SizedBox(
                                            width: cardWidth / 4.5,
                                            height: cardWidth / 4.5,
                                            child: Transform(
                                              transform: Matrix4.identity()
                                                ..scale(-1.0, 1.0,
                                                    1.0), // Mirror the widget horizontally
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(
                                                value: progress,
                                                color: Colors.pink,
                                                strokeWidth: 4,
                                                // backgroundColor: Colors.white24,
                                              ),
                                            ),
                                          ),
                                          // Play/Pause Button
                                          Container(
                                            width: cardWidth / 5.5,
                                            height: cardWidth / 5.5,
                                            decoration: BoxDecoration(
                                              color: Colors.pink,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: cardWidth / 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment
                                      .bottomRight, // Place it at the bottom-right
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: cardHeight * 0.18,
                                        right:
                                            cardWidth / 5), // Adjust position
                                    child: GestureDetector(
                                      onTap: () {
                                        // Implement skip logic here
                                        progress = 1;
                                        remainingSeconds = 0;
                                        stopTimer();

                                        nextCard();
                                      },
                                      child: Icon(
                                        Icons.fast_forward_rounded,
                                        size: cardWidth / 8,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
