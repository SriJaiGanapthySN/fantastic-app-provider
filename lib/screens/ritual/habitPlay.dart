import 'package:fantastic_app_riverpod/screens/main_screen.dart';
import 'package:fantastic_app_riverpod/screens/ritual/notesscreen.dart';
import 'package:fantastic_app_riverpod/services/coaching_service.dart';
import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:fantastic_app_riverpod/widgets/common/generalcompenentfornotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habit_play_provider.dart';

class habitPlay extends ConsumerStatefulWidget {
  final String email;
  final int startIndex; // Add start index parameter

  const habitPlay({
    super.key,
    required this.email,
    this.startIndex = 0, // Default to 0 if not specified
  });

  @override
  ConsumerState<habitPlay> createState() => _TaskrevealState();
}

class _TaskrevealState extends ConsumerState<habitPlay> {
  final CoachingService _coachingService = CoachingService();
  late ScrollController _scrollController;
  Map<String, dynamic>? habitCoachingData;

  String items = '';
  var timestamp = "";
  double NotepadContentHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Set the starting index when the widget initializes
    if (widget.startIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentTaskIndexProvider.notifier).state = widget.startIndex;
      });
    }
  }

  void noteData(QueryDocumentSnapshot currentTask) {
    Map<String, dynamic> taskData = currentTask.data() as Map<String, dynamic>;

    if (taskData.containsKey('notes') && taskData['notes'] != null) {
      if (taskData['notes'] is Map && taskData['notes'].containsKey('items')) {
        ref.read(notesDataProvider.notifier).state = {
          'items': taskData['notes']['items'],
          'timestamp': taskData['notes']['timestamp'].toDate().toString(),
        };
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll if needed
  }

  // Handle task completion (check button press)
  void _onCheckPressed(String animationLink, String taskID) {
    ref.read(audioStateProvider.notifier).state = {
      ...ref.read(audioStateProvider),
      'isAnimationVisible': true,
    };

    // Update task status
    TaskServices().updateHabitStatus(true, taskID, widget.email);

    // Play the animation
    if (animationLink != "") {
      Lottie.network(animationLink, repeat: false);
    }

    // Move to the next task after the animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(currentTaskIndexProvider.notifier).state++;
        ref.read(audioStateProvider.notifier).state = {
          ...ref.read(audioStateProvider),
          'isAnimationVisible': false,
        };
      }
    });
  }

  void _coachingPlay(Map<String, dynamic> task) {
    print("In COACHING");
    // Handle coaching play without audio
    if (habitCoachingData != null) {
      // Add any non-audio related coaching functionality here
      print("Playing coaching content");
    } else {
      print("habitCoachingData is null");
    }
  }

  // Handle skip button press
  void _onSkipPressed() {
    ref.read(isTaskSkippedProvider.notifier).state =
        !ref.read(isTaskSkippedProvider);

    // Move to the next task after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(currentTaskIndexProvider.notifier).state++;
        ref.read(audioStateProvider.notifier).state = {
          ...ref.read(audioStateProvider),
          'isAnimationVisible': false,
        };
      }
    });
  }

  int dayOfWeek() {
    DateTime now = DateTime.now();
    return now.weekday;
  }

  // Handle snooze button press
  void _onSnoozePressed() {
    final isSnoozed = !ref.read(isTaskSnoozedProvider);
    ref.read(isTaskSnoozedProvider.notifier).state = isSnoozed;
  }

  double _calculateDynamicMaxChildSize(
      BuildContext context, Map<String, dynamic> currentTask, String items) {
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
    double coachingAdditionalHeight = 100;

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

  double getDescriptionHeight(
      BuildContext context, Map<String, dynamic> currentTask) {
    String descriptionText = currentTask['descriptionHtml'] ?? '';

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

  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {
      print("Invalid color string: $e");
    }
    return Colors.orange; // Default to orange on error
  }

  Future<String> _dailyCoaching(String habitName) async {
    int day = dayOfWeek();
    if (habitName.contains("Focus")) {
      habitCoachingData = await _coachingService.getHabitCoaching("FOCUS", day);
      print(habitCoachingData);
      return habitCoachingData!["subtitle"];
    }
    if (habitName.contains("Daily")) {
      habitCoachingData =
          await _coachingService.getHabitCoaching("MORNING", day);
      print(habitCoachingData);
      return habitCoachingData!["subtitle"];
    }
    if (habitName.contains("Nightly")) {
      habitCoachingData =
          await _coachingService.getHabitCoaching("NIGHTLY", day);
      print(habitCoachingData);
      return habitCoachingData!["subtitle"];
    }
    return " ";
  }

  @override
  Widget build(BuildContext context) {
    final currentTaskIndex = ref.watch(currentTaskIndexProvider);
    final isTaskSnoozed = ref.watch(isTaskSnoozedProvider);
    final isTaskSkipped = ref.watch(isTaskSkippedProvider);
    final taskData = ref.watch(taskDataProvider);
    final notesData = ref.watch(notesDataProvider);
    final habitCoachingData = ref.watch(habitCoachingDataProvider);
    final audioState = ref.watch(audioStateProvider);

    return Scaffold(
      appBar: null, // Hide the app bar
      body: GestureDetector(
        onPanUpdate: (details) {
          // Handle pan update if needed
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: TaskServices().getUserHabits(widget.email),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var tasks = snapshot.data!;

            // Navigate back when all tasks are completed
            if (currentTaskIndex >= tasks.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ),
                  (route) => false,
                );
              });
              return SizedBox.shrink();
            }

            var currentTask = tasks[currentTaskIndex];

            // Stop audio when the last task's animation finishes
            if (currentTaskIndex == tasks.length - 1 &&
                (audioState['isAnimationVisible'] ?? false)) {
              // Animation completion handled in _onCheckPressed
            }

            return Stack(
              children: [
                Positioned.fill(
                    child: (currentTask.containsKey('backgroundLink') &&
                            currentTask['backgroundLink'] != null &&
                            currentTask['backgroundLink'].isNotEmpty)
                        ? Image.network(
                            currentTask['backgroundLink'],
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorFromString(currentTask[
                                'color']), // Dynamic background color
                            child: Center(
                              child: SvgPicture.network(
                                currentTask["iconUrl"],
                                width: 100,
                                height: 100,
                              ),
                            ),
                          )),

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
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ),

                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      isTaskSnoozed ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: _onSnoozePressed,
                  ),
                ),
                // DraggableScrollableSheet
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.2,
                  maxChildSize: _calculateDynamicMaxChildSize(
                      context, currentTask, items),
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
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final boxWidth = constraints.maxWidth * 1;
                                  var notepadTitle =
                                      currentTask["noteQuestion"];

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
                                        child: currentTask['name']
                                                .contains('Coaching')
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
                                                        FutureBuilder<String>(
                                                          future:
                                                              _dailyCoaching(
                                                                  currentTask[
                                                                      'name']),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const CircularProgressIndicator();
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${snapshot.error}');
                                                            } else if (snapshot
                                                                .hasData) {
                                                              return Text(
                                                                snapshot.data ??
                                                                    '',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              );
                                                            } else {
                                                              return const Text(
                                                                  '');
                                                            }
                                                          },
                                                        )
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
                                                    onPressed: () => {
                                                      if (habitCoachingData !=
                                                          null)
                                                        {
                                                          _coachingPlay(
                                                              habitCoachingData!)
                                                        }
                                                      else
                                                        {
                                                          print(
                                                              "habitCoachingData is null")
                                                        }
                                                    },
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          colorFromString(
                                                              currentTask[
                                                                  "color"]),
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
                                                  Html(
                                                    data: currentTask[
                                                            'descriptionHtml'] ??
                                                        '',
                                                    style: {
                                                      "html": Style(
                                                        color: Colors.white,
                                                        fontSize: FontSize(18),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    },
                                                  ),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 20),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Skip Button
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 45,
                                                      ),
                                                      onPressed: () =>
                                                          _onCheckPressed(
                                                        currentTask.containsKey(
                                                                "completionLottieUrl")
                                                            ? currentTask[
                                                                'completionLottieUrl']
                                                            : "",
                                                        currentTask['objectId'],
                                                      ),
                                                      style:
                                                          IconButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        shape:
                                                            const CircleBorder(),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 150,
                                                      width: 150,
                                                      child: Visibility(
                                                        visible: audioState[
                                                                'isAnimationVisible'] ??
                                                            false,
                                                        child: currentTask
                                                                .containsKey(
                                                                    "completionLottieUrl")
                                                            ? Lottie.network(
                                                                currentTask[
                                                                    'completionLottieUrl'],
                                                                repeat: false,
                                                                width: 150,
                                                                height: 150,
                                                              )
                                                            : Container(),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // Snooze Button
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                              'objectId'],
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
                                                    overflow:
                                                        TextOverflow.visible,
                                                    softWrap: true,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: (items.isNotEmpty)
                                                      ? () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  GeneralComponentScreen(
                                                                email: widget
                                                                    .email,
                                                                taskID: currentTask[
                                                                    'objectId'],
                                                                title:
                                                                    notepadTitle,
                                                                timestamp:
                                                                    timestamp,
                                                                items: items,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                                  icon: Icon(
                                                    Icons.book,
                                                    color: (items.isNotEmpty)
                                                        ? Colors.white
                                                        : Colors.grey,
                                                    size: 30,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (items.isNotEmpty) ...[
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
