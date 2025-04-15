import 'package:fantastic_app_riverpod/screens/main_screen.dart';
import 'package:fantastic_app_riverpod/screens/ritual/audio.dart';
import 'package:fantastic_app_riverpod/screens/ritual/notesscreen.dart';
import 'package:fantastic_app_riverpod/services/coaching_service.dart';
import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:fantastic_app_riverpod/widgets/common/generalcompenentfornotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:audioplayers/audioplayers.dart';

class habitPlay extends StatefulWidget {
  final String email;

  const habitPlay({
    super.key,
    required this.email,
  });

  @override
  State<habitPlay> createState() => _TaskrevealState();
}

class _TaskrevealState extends State<habitPlay> {
  final CoachingService _coachingService = CoachingService();
  bool _isAnimationVisible = false;
  int _currentIndex = 0; // Track the current task
  bool _isSnoozed = false; // Track snooze state
  bool _isSkiped = false; // Track if the task is skipped
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  final AudioPlayer _audioPlayerBgm = AudioPlayer(); // Audio player instance
  final AudioPlayer _audioPlayerDrag = AudioPlayer(); // Audio player instance
  late ScrollController _scrollController;
  bool _isPlayingAudio = false;
  Map<String, dynamic>? habitCoachingData;

  String items = '';
  var timestamp = "";
  double NotepadContentHeight = 0;

  @override
  void initState() {
    super.initState();
    // _setupAudioContext();
    _playBgm();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _setupAudioContext() async {
    await _audioPlayerBgm.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  // Play audio if snooze is not active
  void _playAudio(String audioLink) async {
    if (!_isSnoozed) {
      await _audioPlayer.play(UrlSource(audioLink));
    }
  }

  void _playBgm() async {
    if (!_isSnoozed) {
      // await _audioPlayerBgm.setAsset('assets/audio/bgm_task_reveal.m4a');
      // await _audioPlayerBgm.play();
      await _audioPlayerBgm.play(AssetSource("audio/bgm_task_reveal.m4a"));
    }
  }

  void _stopBgm() async {
    await _audioPlayerBgm.stop();
  }

  void _playDragAudio() async {
    if (!_isSnoozed) {
      await _audioPlayerDrag.play(AssetSource("audio/drag_task_reveal.m4a"));
    }
  }

  // void noteData(QueryDocumentSnapshot currentTask) {
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
    _audioPlayer.stop();
    _audioPlayerBgm.stop();
    _audioPlayerDrag.stop();
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
    TaskServices().updateHabitStatus(true, taskID, widget.email);

    // Play the animation
    if (animationLink != "") {
      Lottie.network(animationLink, repeat: false);
    }

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

  // void _coachingPlay(QueryDocumentSnapshot task) {
  void _coachingPlay(Map<String, dynamic> task) {
    print("In COACHING");
    _stopAudio();
    _stopBgm();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlayAudio(
                email: widget.email,
                coachingData: task,
              )),
    );
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

  int dayOfWeek() {
    DateTime now = DateTime.now();
    return now
        .weekday; // Adjust because DateTime.weekday starts from 1 (Monday) to 7 (Sunday)
  }

  // Handle snooze button press
  void _onSnoozePressed() {
    setState(() {
      _isSnoozed = !_isSnoozed;
    });
    if (_isSnoozed) {
      _audioPlayer.setVolume(0); // Set volume to 0 (mute)
      _audioPlayerDrag.setVolume(0);
      _audioPlayerBgm.setVolume(0);
    } else {
      _audioPlayer.setVolume(1); // Set volume back to normal (unmute)
      _audioPlayerDrag.setVolume(1);
      _audioPlayerBgm.setVolume(1);
    }
    // Stop the audio when snooze is pressed
    // _stopAudio();
    // _stopBgm();
  }

  double _calculateDynamicMaxChildSize(
      // BuildContext context, QueryDocumentSnapshot currentTask, String items) {

      BuildContext context,
      Map<String, dynamic> currentTask,
      String items) {
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
    // currentTask['category'] == 'Coaching' ? 100 : 0;

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
      // BuildContext context, QueryDocumentSnapshot currentTask) {
      BuildContext context,
      Map<String, dynamic> currentTask) {
    // This can be based on the content of the description. For now, assuming average content height.
    // String descriptionText = currentTask['category'] == 'Coaching'
    //     ? currentTask['subtitle'] ?? ''
    //     : currentTask['descriptionHtml'] ?? '';

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
    return Scaffold(
      appBar: null, // Hide the app bar
      body: GestureDetector(
        onPanUpdate: (details) {
          // Detect drag and play audio
          _playDragAudio();
        },
        // child: StreamBuilder<QuerySnapshot>(
        //   stream: TaskServices().getdailyTasks(widget.email),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: TaskServices().getUserHabits(widget.email),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var tasks = snapshot.data!;
            // var tasks = snapshot.data!.docs;

            // Navigate back when all tasks are completed
            if (_currentIndex >= tasks.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _stopAudio();
                _stopBgm();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         // Routinelistscreen(email: widget.email),
                //         MainScreen(email: widget.email),
                //   ),
                // );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ),
                  (route) => false, // Removes all previous routes
                );
              });
              return SizedBox.shrink();
            }

            var currentTask = tasks[_currentIndex];

            // noteData(currentTask);

            // Play audio when background is shown
            if (!_isSnoozed) {
              // _playAudio(currentTask['audioLink']);
              if (currentTask.containsKey('voiceUrl')) {
                _playAudio(currentTask['voiceUrl']);
              }
            }

            // Stop audio when the last task's animation finishes
            if (_currentIndex == tasks.length - 1 && _isAnimationVisible) {
              _stopAudio();
            }

            return Stack(
              children: [
                // Background Image
                // Positioned.fill(
                //   child: Image.network(
                //     currentTask['backgroundLink'],
                //     fit: BoxFit.cover,
                //   ),
                // ),

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
                      textAlign: TextAlign.center, // Center align the text
                      softWrap: true,
                    ),
                  ),
                ),

                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      _isSnoozed ? Icons.volume_off : Icons.volume_up,
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
                                                        // Text(
                                                        //   _dailyCoaching(currentTask['name']) ??
                                                        //       '',
                                                        //   style:
                                                        //       const TextStyle(
                                                        //     color: Colors.white,
                                                        //     fontSize: 18,
                                                        //   ),
                                                        //   textAlign:
                                                        //       TextAlign.left,
                                                        // ),

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
                                                              return const CircularProgressIndicator(); // Or any loading indicator
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${snapshot.error}');
                                                            } else if (snapshot
                                                                .hasData) {
                                                              return Text(
                                                                snapshot.data ??
                                                                    '', // Safely using the data once it's loaded
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
                                                                  ''); // Handle case when there's no data
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
                                                              habitCoachingData!) // Use the non-nullable value
                                                        }
                                                      else
                                                        {
                                                          // Handle the case where habitCoachingData is null (if needed)
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
                                                        '', // Pass HTML content here
                                                    style: {
                                                      "html": Style(
                                                        color: Colors
                                                            .white, // Text color
                                                        fontSize: FontSize(
                                                            18), // Font size
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    },
                                                    // Text alignment
                                                  ),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Buttons Box
                                      // Container(
                                      //   width: boxWidth,
                                      //   padding: const EdgeInsets.all(12),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.black.withOpacity(0.6),
                                      //     borderRadius:
                                      //         BorderRadius.circular(15),
                                      //   ),
                                      //   child: Column(
                                      //     children: [
                                      //       const Text(
                                      //         "Today",
                                      //         style: TextStyle(
                                      //           color: Colors.white,
                                      //           fontSize: 18,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //       ),
                                      //       const Divider(
                                      //         color: Colors.white,
                                      //         thickness: 1,
                                      //       ),
                                      //       Wrap(
                                      //         spacing: 20,
                                      //         alignment: WrapAlignment.center,
                                      //         children: [
                                      //           // Skip Button
                                      //           Column(
                                      //             children: [
                                      //               IconButton(
                                      //                 onPressed: _onSkipPressed,
                                      //                 icon: const Icon(
                                      //                   Icons.skip_next,
                                      //                   color: Colors.white,
                                      //                   size: 35,
                                      //                 ),
                                      //               ),
                                      //               const Text(
                                      //                 "Skip",
                                      //                 style: TextStyle(
                                      //                   color: Colors.white,
                                      //                   fontSize: 18,
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //           // Check Button with Animation
                                      //           Stack(
                                      //             alignment: Alignment.center,
                                      //             children: [

                                      //               IconButton(
                                      //                 icon: const Icon(
                                      //                   Icons.check,
                                      //                   color: Colors.white,
                                      //                   size: 45,
                                      //                 ),
                                      //                 onPressed: () =>
                                      //                     _onCheckPressed(
                                      //                         // currentTask[
                                      //                         //     'animationLink'],
                                      //                         currentTask.containsKey(
                                      //                                 "completionLottieUrl")
                                      //                             ? currentTask[
                                      //                                 'completionLottieUrl']
                                      //                             : "",
                                      //                         // currentTask[
                                      //                         //     'objectID']),
                                      //                         currentTask[
                                      //                             'objectId']),
                                      //                 style:
                                      //                     IconButton.styleFrom(
                                      //                   backgroundColor:
                                      //                       Colors.pink,
                                      //                   shape:
                                      //                       const CircleBorder(),
                                      //                 ),
                                      //               ),
                                      //               SizedBox(
                                      //                 height: 150,
                                      //                 width: 100,
                                      //                 child: Visibility(
                                      //                   visible:
                                      //                       _isAnimationVisible,
                                      //                   child: currentTask
                                      //                           .containsKey(
                                      //                               "completionLottieUrl")
                                      //                       ? Lottie.network(
                                      //                           currentTask[
                                      //                               'completionLottieUrl'],
                                      //                           repeat: false,
                                      //                           width:
                                      //                               500, // Adjust size as needed
                                      //                           height: 500,
                                      //                         )
                                      //                       : Container(), // Empty container if no Lottie URL exists
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //           // Snooze Button
                                      //           Column(
                                      //             children: [
                                      //               IconButton(
                                      //                 onPressed:
                                      //                     _onSnoozePressed,
                                      //                 icon: const Icon(
                                      //                   Icons.repeat,
                                      //                   color: Colors.white,
                                      //                   size: 35,
                                      //                 ),
                                      //               ),
                                      //               const Text(
                                      //                 "Snooze",
                                      //                 style: TextStyle(
                                      //                   color: Colors.white,
                                      //                   fontSize: 18,
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

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
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center, // Center the buttons horizontally
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
                                                        visible:
                                                            _isAnimationVisible,
                                                        child: currentTask
                                                                .containsKey(
                                                                    "completionLottieUrl")
                                                            ? Lottie.network(
                                                                currentTask[
                                                                    'completionLottieUrl'],
                                                                repeat: false,
                                                                width:
                                                                    150, // Adjust size as needed
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
