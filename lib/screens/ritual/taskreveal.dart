import 'package:fantastic_app_riverpod/screens/main_screen.dart';
import 'package:fantastic_app_riverpod/screens/ritual/notesscreen.dart';
import 'package:fantastic_app_riverpod/screens/ritual_screen.dart';
import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:fantastic_app_riverpod/widgets/common/generalcompenentfornotes.dart';
import 'package:fantastic_app_riverpod/widgets/habit_list.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:audioplayers/audioplayers.dart';

class Taskreveal extends StatefulWidget {
  final String email;

  const Taskreveal({
    super.key,
    required this.email,
  });

  @override
  State<Taskreveal> createState() => _TaskrevealState();
}

class _TaskrevealState extends State<Taskreveal> {
  bool _isAnimationVisible = false;
  int _currentIndex = 0; // Track the current task
  bool _isSnoozed = false; // Track snooze state
  bool _isSkiped = false; // Track if the task is skipped
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  final AudioPlayer _audioPlayerBgm = AudioPlayer(); // Audio player instance
  final AudioPlayer _audioPlayerDrag = AudioPlayer(); // Audio player instance
  late ScrollController _scrollController;
  bool _isPlayingAudio = false;

  String items = '';
  var timestamp = "";
  double NotepadContentHeight = 0;

  @override
  void initState() {
    super.initState();
    _playBgm();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  // Play audio if snooze is not active
  void _playAudio(String audioLink) async {
    if (!_isSnoozed) {
      await _audioPlayer.play(UrlSource(audioLink));
    }
  }

  void _playBgm() async {
    await _audioPlayerBgm.play(AssetSource("audio/bgm_task_reveal.m4a"));
  }

  void _stopBgm() async {
    await _audioPlayerBgm.stop();
  }

  void _playDragAudio() async {
    await _audioPlayerDrag.play(AssetSource("audio/drag_task_reveal.m4a"));
  }

  void noteData(QueryDocumentSnapshot currentTask) {
    Map<String, dynamic> taskData = currentTask.data() as Map<String, dynamic>;

// Check if 'notes' field exists and if 'notes' is a valid map
    items = '';
    if (taskData.containsKey('notes') && taskData['notes'] != null) {
      print(taskData);
      // Check if 'notes' is a Map and contains 'items'
      if (taskData['notes'] is Map && taskData['notes'].containsKey('items')) {
        print("HOLLLLL");
        items = taskData['notes']['items']; // Assign 'items' from 'notes'
        Timestamp firebaseTimestamp = taskData['notes']['timestamp'];
        DateTime dateTime =
            firebaseTimestamp.toDate(); // Convert Timestamp to DateTime
        timestamp = dateTime.toString();
      }
    }
  }

  // Stop the audio
  void _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isPlayingAudio) {
      _playdragAudio();
    }
  }

  void _playdragAudio() async {
    setState(() {
      _isPlayingAudio = true;
    });
    await _audioPlayerDrag.play(AssetSource('audio/drag_task_reveal.m4a'));
    setState(() {
      _isPlayingAudio = false;
    });
  }

  // Handle task completion (check button press)
  void _onCheckPressed(String animationLink, String taskID) {
    setState(() {
      _isAnimationVisible = true;
    });

    // Update task status
    TaskServices().updateTaskStatus(true, taskID, widget.email);

    // Play the animation
    Lottie.network(animationLink, repeat: false);

    // Move to the next task after the animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _isAnimationVisible = false;
        });
      }
    });
  }

  void _coachingPlay(QueryDocumentSnapshot task) {
    print("In COACHING");
    _stopAudio();
    _stopBgm();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => PlayAudio(
    //             email: widget.email,
    //             couching: task,
    //           )),
    // );
  }

  // Handle skip button press
  void _onSkipPressed() {
    setState(() {
      _isSkiped = !_isSkiped;
    });

    // Move to the next task after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _isAnimationVisible = false;
        });
      }
    });
  }

  // Handle snooze button press
  void _onSnoozePressed() {
    setState(() {
      _isSnoozed = !_isSnoozed;
    });

    // Stop the audio when snooze is pressed
    _stopAudio();
  }

  double _calculateDynamicMaxChildSize(
      BuildContext context, QueryDocumentSnapshot currentTask, String items) {
    // Get screen height
    double screenHeight = MediaQuery.of(context).size.height;

    // Fixed heights for the arrow and spacing
    double arrowHeight = 48; // Height of the arrow button
    double spacingHeight = 16; // Spacing after arrow and other boxes

    // Calculate dynamic content height
    double descriptionHeight = getDescriptionHeight(context,
        currentTask); // Custom function to calculate description height based on content
    double notepadContent = getNotepadContentHeight(items);
    double buttonBoxHeight =
        200; // Estimated height of the button box (you can adjust this based on your UI)
    double notepadBoxHeight = 100; // Fixed height of the notepad box

    // Add additional height for "Coaching" tasks (Play button, subtitle, etc.)
    double coachingAdditionalHeight =
        currentTask['category'] == 'Coaching' ? 100 : 0;

    // Total content height
    double totalContentHeight = descriptionHeight +
        buttonBoxHeight +
        notepadBoxHeight +
        arrowHeight +
        spacingHeight +
        coachingAdditionalHeight +
        notepadContent;

    // Calculate the max scrollable area as a fraction of the screen height
    double maxChildSize = totalContentHeight / screenHeight;

    // Return the maximum scrollable size, ensuring it doesn't exceed 1 (100% of screen height)
    return maxChildSize > 1.0 ? 1.0 : maxChildSize;
  }

// Custom function to calculate the dynamic height of the description box based on content
  double getDescriptionHeight(
      BuildContext context, QueryDocumentSnapshot currentTask) {
    // This can be based on the content of the description. For now, assuming average content height.
    String descriptionText = currentTask['category'] == 'Coaching'
        ? currentTask['subtitle'] ?? ''
        : currentTask['descriptionHtml'] ?? '';

    double textHeight = (descriptionText.length / 50).ceil() *
        24.0; // Approximation: 50 characters per line, 24px per line

    // Limit the height for non-coaching categories to a reasonable amount (200)
    return textHeight > 200
        ? 200
        : textHeight; // Limit to a max height of 200 for this box
  }

  double getNotepadContentHeight(String data) {
    if (data.isNotEmpty) {
      double textHeight = (data.length / 50).ceil() *
          24.0; // Approximation: 50 characters per line, 24px per line

      // Limit the height for non-coaching categories to a reasonable amount (200)
      NotepadContentHeight =
          textHeight * 2 + 10 > 200 ? 200 : textHeight * 2 + 10;
    } else {
      NotepadContentHeight = 0;
    }
    return NotepadContentHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Hide the app bar
      body: GestureDetector(
        onPanUpdate: (details) {
          // Detect drag and play audio
          _playDragAudio();
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: TaskServices().getdailyTasks("test03@gmail.com"),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var tasks = snapshot.data!.docs;

            // Navigate back when all tasks are completed
            if (_currentIndex >= tasks.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _stopAudio();
                _stopBgm();
                // Fix navigation to RitualScreen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              });
              return Center(child: CircularProgressIndicator());
            }

            var currentTask = tasks[_currentIndex];

            noteData(currentTask);

            // Play audio when background is shown
            if (!_isSnoozed) {
              _playAudio(currentTask['audioLink']);
            }

            // Stop audio when the last task's animation finishes
            if (_currentIndex == tasks.length - 1 && _isAnimationVisible) {
              _stopAudio();
            }

            return Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    currentTask['backgroundLink'],
                    fit: BoxFit.cover,
                  ),
                ),
                // Title Positioned 20% from the Top
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      currentTask['name'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // DraggableScrollableSheet
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.2,
                  maxChildSize: _calculateDynamicMaxChildSize(
                      context, currentTask, items), // Use dynamic maxChildSize
                  builder: (context, scrollController) {
                    _scrollController = scrollController;

                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Drag Handle with Upward Arrow
                              Center(
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 16), // Spacing below arrow
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final boxWidth = constraints.maxWidth * 1;
                                  var notepadTitle = "NOTEPAD";

                                  return Column(
                                    children: [
                                      // Description Box - Height depends on content
                                      Container(
                                        width: boxWidth,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: currentTask['category'] ==
                                                'Coaching'
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Left Side (Name and Subtitle)
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          currentTask['name'] ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          currentTask[
                                                                  'subtitle'] ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Right Side (Play Button inside red circle)
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 35,
                                                    ),
                                                    onPressed: () =>
                                                        _coachingPlay(
                                                            currentTask),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(50, 50),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  Text(
                                                    currentTask[
                                                            'descriptionHtml'] ??
                                                        '',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Buttons Box
                                      Container(
                                        width: boxWidth,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Today",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.white,
                                              thickness: 1,
                                            ),
                                            Wrap(
                                              spacing: 20,
                                              alignment: WrapAlignment.center,
                                              children: [
                                                // Skip Button
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: _onSkipPressed,
                                                      icon: const Icon(
                                                        Icons.skip_next,
                                                        color: Colors.white,
                                                        size: 35,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Skip",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Check Button with Animation
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: Visibility(
                                                        visible:
                                                            _isAnimationVisible,
                                                        child: Lottie.network(
                                                          currentTask[
                                                              'animationLink'],
                                                          repeat: false,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 45,
                                                      ),
                                                      onPressed: () =>
                                                          _onCheckPressed(
                                                              currentTask[
                                                                  'animationLink'],
                                                              currentTask[
                                                                  'objectID']),
                                                      style:
                                                          IconButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        shape:
                                                            const CircleBorder(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Snooze Button
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed:
                                                          _onSnoozePressed,
                                                      icon: const Icon(
                                                        Icons.repeat,
                                                        color: Colors.white,
                                                        size: 35,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Snooze",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width: boxWidth,
                                        height: 80.0 + NotepadContentHeight,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Align content to start
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start, // Align text to the top if it's multiline
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Notesscreen(
                                                          email: widget.email,
                                                          taskID: currentTask[
                                                              'objectID'],
                                                          title: notepadTitle,
                                                          timestamp: "",
                                                          items: items,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    notepadTitle,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow
                                                        .visible, // Make sure it wraps correctly
                                                    softWrap:
                                                        true, // This is default and allows text to wrap
                                                    textAlign: TextAlign
                                                        .center, // Center-align the text
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: (items.isNotEmpty)
                                                      ? () {
                                                          // Navigate only if 'items' is not null and not empty
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  GeneralComponentScreen(
                                                                email: widget
                                                                    .email,
                                                                taskID: currentTask[
                                                                    'objectID'],
                                                                title:
                                                                    notepadTitle,
                                                                timestamp:
                                                                    timestamp,
                                                                items: items,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      : null, // Disable the button if 'items' is null or empty
                                                  icon: Icon(
                                                    Icons.book,
                                                    color: (items.isNotEmpty)
                                                        ? Colors.white
                                                        : Colors
                                                            .grey, // White if 'items' is not empty, grey if empty
                                                    size: 30,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (items.isNotEmpty) ...[
                                              // Show divider and text only when items is not empty
                                              const Divider(
                                                color: Colors.white,
                                                thickness: 1,
                                                height: 20,
                                              ),
                                              Text(
                                                items,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
