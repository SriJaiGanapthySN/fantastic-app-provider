import 'package:fantastic_app_riverpod/features/ritual/presentation/screens/notesscreen.dart';
import 'package:fantastic_app_riverpod/features/coaching/data/services/coaching_service.dart';
import 'package:fantastic_app_riverpod/features/ritual/data/services/task_services.dart';
import 'package:fantastic_app_riverpod/core/common/widgets/generalcompenentfornotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/common/providers/nav_provider.dart';
import '../providers/habit_play_provider.dart';
import '../providers/habitplay_video_provider.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _audioPlayerBgm = AudioPlayer(); // BGM audio player
  final CoachingService _coachingService = CoachingService();
  late ScrollController _scrollController;
  Map<String, dynamic>? habitCoachingData;

  // Cache for tasks to avoid repeated FutureBuilder calls
  List<Map<String, dynamic>>? _cachedTasks;
  bool _isLoadingTasks = true;

  // Cache for coaching data to avoid repeated API calls
  final Map<String, String> _coachingCache = {};

  String items = '';
  var timestamp = "";
  double NotepadContentHeight = 0;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Start BGM with looping
    await _playBgm();

    // Load tasks once
    await _loadTasks();

    // Set the starting index when the widget initializes
    if (widget.startIndex > 0 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(currentTaskIndexProvider.notifier).state = widget.startIndex;
        }
      });
    }
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await TaskServices().getUserHabits(widget.email);
      if (mounted) {
        setState(() {
          _cachedTasks = tasks;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      if (mounted) {
        setState(() {
          _isLoadingTasks = false;
        });
      }
    }
  }

  Future<void> _playBgm() async {
    try {
      await _audioPlayerBgm.setReleaseMode(ReleaseMode.loop);
      await _audioPlayerBgm.play(AssetSource("audio/bgm_task_reveal.m4a"));
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> _stopBgm() async {
    try {
      await _audioPlayerBgm.stop();
    } catch (e) {
      print('Error stopping BGM: $e');
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
    // Stop and dispose audio player
    _stopBgm();
    _audioPlayerBgm.dispose();

    // Remove scroll listener and dispose controller
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // Clear caches to free memory
    _cachedTasks?.clear();
    _cachedTasks = null;
    _coachingCache.clear();

    // Dispose video provider safely
    // Note: The provider itself will be disposed by Riverpod when no longer used
    try {
      if (mounted) {
        final videoNotifier = ref.read(habitPlayVideoProvider.notifier);
        videoNotifier.dispose();
      }
    } catch (e) {
      print('HabitPlay: Error disposing video provider: $e');
    }

    super.dispose();
  }

  void _onScroll() {
    // Handle scroll if needed
  }

  // Handle task completion (check button press)
  void _onCheckPressed(String animationLink, String taskID) {
    if (!mounted) return;

    ref.read(audioStateProvider.notifier).state = {
      ...ref.read(audioStateProvider),
      'isAnimationVisible': true,
    };

    // Update task status asynchronously
    TaskServices()
        .updateHabitStatus(true, taskID, widget.email)
        .catchError((e) {
      print('Error updating habit status: $e');
    });

    // Guard asynchronous operation with mounted check
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
    // Handle coaching play without audio
    if (habitCoachingData != null) {
      // Add any non-audio related coaching functionality here
    } else {}
  }

  // Handle skip button press
  void _onSkipPressed() {
    if (!mounted) return;

    ref.read(isTaskSkippedProvider.notifier).state =
        !ref.read(isTaskSkippedProvider);

    // Guard asynchronous operation with mounted check
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
    if (!mounted) return;

    final isSnoozed = !ref.read(isTaskSnoozedProvider);
    ref.read(isTaskSnoozedProvider.notifier).state = isSnoozed;

    // Pause/resume video based on snooze state
    try {
      if (isSnoozed) {
        ref.read(habitPlayVideoProvider.notifier).pauseVideo();
      } else {
        ref.read(habitPlayVideoProvider.notifier).resumeVideo();
      }
    } catch (e) {
      print('Error toggling video playback: $e');
    }
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
    } catch (e) {}
    return Colors.orange; // Default to orange on error
  }

  // Build fallback background when video fails or is not available
  Widget _buildFallbackBackground(
    Map<String, dynamic> currentTask,
    String? fallbackImageUrl,
    BuildContext context,
  ) {
    if (fallbackImageUrl != null && fallbackImageUrl.isNotEmpty) {
      return Image.network(
        fallbackImageUrl,
        fit: BoxFit.cover,
        cacheWidth: MediaQuery.of(context).size.width.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return _buildColorBackground(currentTask);
        },
      );
    }
    return _buildColorBackground(currentTask);
  }

  // Build solid color background with icon
  Widget _buildColorBackground(Map<String, dynamic> currentTask) {
    return Container(
      color: colorFromString(currentTask['color'] ?? '#FF9800'),
      child: Center(
        child: SvgPicture.network(
          currentTask["iconUrl"] ?? "",
          width: 100,
          height: 100,
          placeholderBuilder: (context) => const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }

  Future<String> _dailyCoaching(String habitName) async {
    // Check cache first to avoid repeated API calls
    if (_coachingCache.containsKey(habitName)) {
      return _coachingCache[habitName]!;
    }

    int day = dayOfWeek();
    String coachingType = '';

    if (habitName.contains("Focus")) {
      coachingType = "FOCUS";
    } else if (habitName.contains("Daily")) {
      coachingType = "MORNING";
    } else if (habitName.contains("Nightly")) {
      coachingType = "NIGHTLY";
    } else {
      return " ";
    }

    try {
      habitCoachingData =
          await _coachingService.getHabitCoaching(coachingType, day);
      final subtitle = habitCoachingData?["subtitle"] ?? " ";

      // Cache the result
      _coachingCache[habitName] = subtitle;

      return subtitle;
    } catch (e) {
      print('Error fetching coaching data: $e');
      return " ";
    }
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
    final videoState = ref.watch(habitPlayVideoProvider);

    return Scaffold(
      appBar: null, // Hide the app bar
      body: GestureDetector(
        onPanUpdate: (details) {
          // Handle pan update if needed
        },
        child: _buildTaskView(
          context,
          currentTaskIndex,
          isTaskSnoozed,
          isTaskSkipped,
          taskData,
          notesData,
          habitCoachingData,
          audioState,
          videoState,
        ),
      ),
    );
  }

  Widget _buildTaskView(
    BuildContext context,
    int currentTaskIndex,
    bool isTaskSnoozed,
    bool isTaskSkipped,
    Map<String, dynamic>? taskData,
    Map<String, dynamic> notesData,
    Map<String, dynamic>? habitCoachingData,
    Map<String, bool> audioState,
    HabitPlayVideoState videoState,
  ) {
    // Show loading indicator while tasks are being loaded
    if (_isLoadingTasks || _cachedTasks == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Loading your habits...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    var tasks = _cachedTasks!;

    // Navigate back when all tasks are completed
    if (currentTaskIndex >= tasks.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Pop back to the first route (assumed to be the original MainScreen)
        Navigator.popUntil(context, (route) => route.isFirst);

        // Ensure the main screen tab is set to Ritual (index 1) so the
        // BottomNavBar and PageView remain in a consistent state.
        try {
          ref.read(selectedTabProvider.notifier).state = 1;
        } catch (e) {
          // If we can't update the provider for any reason, just ignore
          // — popping back should restore the UI state in most cases.
          print('Error resetting selectedTabProvider: $e');
        }
      });
      return const SizedBox.shrink();
    }

    var currentTask = tasks[currentTaskIndex];

    // Initialize video controller when the task changes
    String? videoUrl = currentTask['videoUrl'];
    String? fallbackImageUrl = currentTask['backgroundLink'];

    // Only initialize video if URL exists and is different from current
    if (videoUrl != null &&
        videoUrl.isNotEmpty &&
        videoState.currentVideoUrl != videoUrl &&
        mounted) {
      Future.microtask(() {
        if (mounted) {
          try {
            ref.read(habitPlayVideoProvider.notifier).initializeVideo(videoUrl);
          } catch (e) {
            print('HabitPlay: Error initializing video: $e');
          }
        }
      });
    }

    // Show loading screen while video is loading (but only for a reasonable time)
    if (videoState.isLoading &&
        videoUrl != null &&
        videoUrl.isNotEmpty &&
        !videoState.hasError) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Loading your habit...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Stop audio when the last task's animation finishes
    if (currentTaskIndex == tasks.length - 1 &&
        (audioState['isAnimationVisible'] ?? false)) {
      // Animation completion handled in _onCheckPressed
    }

    return Stack(
      children: [
        // Background Video or Fallback Image/Color
        Positioned.fill(
          child: RepaintBoundary(
            child: videoState.isInitialized &&
                    videoState.controller != null &&
                    !videoState.hasError
                ? Builder(
                    builder: (context) {
                      try {
                        final controller = videoState.controller!;
                        // Check if controller value is valid
                        if (!controller.value.isInitialized ||
                            controller.value.hasError) {
                          return _buildFallbackBackground(
                              currentTask, fallbackImageUrl, context);
                        }

                        // Ensure video size is valid
                        if (controller.value.size.width == 0 ||
                            controller.value.size.height == 0) {
                          return _buildFallbackBackground(
                              currentTask, fallbackImageUrl, context);
                        }

                        return FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.size.width,
                            height: controller.value.size.height,
                            child: VideoPlayer(controller),
                          ),
                        );
                      } catch (e) {
                        print('HabitPlay: Video rendering error: $e');
                        return _buildFallbackBackground(
                            currentTask, fallbackImageUrl, context);
                      }
                    },
                  )
                : _buildFallbackBackground(
                    currentTask, fallbackImageUrl, context),
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
          minChildSize: 0.3,
          maxChildSize: 0.6,
          expand: true,
          builder: (context, scrollController) {
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
                          var notepadTitle = currentTask["noteQuestion"];

                          return Column(
                            children: [
                              // Description Box - Height depends on content
                              Container(
                                width: boxWidth,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: currentTask['name'].contains('Coaching')
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Left Side (Name and Subtitle)
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  currentTask['name'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                const SizedBox(height: 8),
                                                FutureBuilder<String>(
                                                  future: _dailyCoaching(
                                                      currentTask['name']),
                                                  builder: (context, snapshot) {
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
                                                        snapshot.data ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      );
                                                    } else {
                                                      return const Text('');
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
                                              if (habitCoachingData != null)
                                                {
                                                  _coachingPlay(
                                                      habitCoachingData[
                                                          "voiceUrl"]),
                                                }
                                              else
                                                {
                                                  print(
                                                      "habitCoachingData is null")
                                                }
                                            },
                                            style: IconButton.styleFrom(
                                              backgroundColor: colorFromString(
                                                  currentTask["color"]),
                                              shape: const CircleBorder(),
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
                                                textAlign: TextAlign.center,
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
                                  borderRadius: BorderRadius.circular(15),
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
                                          mainAxisSize: MainAxisSize.min,
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
                                              onPressed: () => _onCheckPressed(
                                                currentTask.containsKey(
                                                        "completionLottieUrl")
                                                    ? currentTask[
                                                        'completionLottieUrl']
                                                    : "",
                                                currentTask['objectId'],
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.pink,
                                                shape: const CircleBorder(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 200,
                                              width: 150,
                                              child: Visibility(
                                                visible: audioState[
                                                        'isAnimationVisible'] ??
                                                    false,
                                                child: currentTask.containsKey(
                                                        "completionLottieUrl")
                                                    ? Lottie.network(
                                                        currentTask[
                                                            'completionLottieUrl'],
                                                        repeat: false,
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          print(
                                                              'Error loading Lottie: $error');
                                                          return const SizedBox
                                                              .shrink();
                                                        },
                                                      )
                                                    : const SizedBox.shrink(),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Snooze Button
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: _onSnoozePressed,
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
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                  taskID:
                                                      currentTask['objectId'],
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.visible,
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
                                                        email: widget.email,
                                                        taskID: currentTask[
                                                            'objectId'],
                                                        title: notepadTitle,
                                                        timestamp: timestamp,
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
  }
}
