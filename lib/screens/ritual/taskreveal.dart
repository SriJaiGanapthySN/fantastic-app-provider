import 'package:fantastic_app_riverpod/screens/ritual/notesscreen.dart';
import 'package:fantastic_app_riverpod/screens/ritual_screen.dart';
import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:fantastic_app_riverpod/widgets/common/generalcompenentfornotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/habit_play_provider.dart';

class Taskreveal extends ConsumerStatefulWidget {
  final String email;

  const Taskreveal({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<Taskreveal> createState() => _TaskrevealState();
}

class _TaskrevealState extends ConsumerState<Taskreveal> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _audioPlayerBgm = AudioPlayer();
  final AudioPlayer _audioPlayerDrag = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playBgm();
  }

  void _playAudio(String audioLink) async {
    if (!ref.read(isTaskSnoozedProvider)) {
      await _audioPlayer.play(UrlSource(audioLink));
      ref.read(audioStateProvider.notifier).state = {
        ...ref.read(audioStateProvider),
        'isPlaying': true,
      };
    }
  }

  void _playBgm() async {
    if (!ref.read(isTaskSnoozedProvider)) {
    await _audioPlayerBgm.play(AssetSource("audio/bgm_task_reveal.m4a"));
      ref.read(audioStateProvider.notifier).state = {
        ...ref.read(audioStateProvider),
        'isBgmPlaying': true,
      };
    }
  }

  void _stopBgm() async {
    await _audioPlayerBgm.stop();
    ref.read(audioStateProvider.notifier).state = {
      ...ref.read(audioStateProvider),
      'isBgmPlaying': false,
    };
  }

  void _playDragAudio() async {
    if (!ref.read(isTaskSnoozedProvider)) {
    await _audioPlayerDrag.play(AssetSource("audio/drag_task_reveal.m4a"));
      ref.read(audioStateProvider.notifier).state = {
        ...ref.read(audioStateProvider),
        'isDragPlaying': true,
      };
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

  void _stopAudio() async {
    await _audioPlayer.stop();
    ref.read(audioStateProvider.notifier).state = {
      ...ref.read(audioStateProvider),
      'isPlaying': false,
    };
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioPlayerBgm.dispose();
    _audioPlayerDrag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTaskIndex = ref.watch(currentTaskIndexProvider);
    final isTaskSnoozed = ref.watch(isTaskSnoozedProvider);
    final isTaskSkipped = ref.watch(isTaskSkippedProvider);
    final taskData = ref.watch(taskDataProvider);
    final notesData = ref.watch(notesDataProvider);

    // Your existing build method implementation here
    // Use the providers instead of local state variables
    return Container(); // Replace with your actual widget tree
  }
}
