import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/task_services.dart';
import '../services/coaching_service.dart';

// Provider to track the current task index
final currentTaskIndexProvider = StateProvider<int>((ref) => 0);

// Provider to track if a task is snoozed
final isTaskSnoozedProvider = StateProvider<bool>((ref) => false);

// Provider to track if a task is skipped
final isTaskSkippedProvider = StateProvider<bool>((ref) => false);

// Provider to manage the audio state
final audioStateProvider = StateProvider<Map<String, bool>>((ref) => {
  'isPlaying': false,
  'isBgmPlaying': false,
  'isDragPlaying': false,
});

// Provider to manage the task data
final taskDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Provider to manage the notes data
final notesDataProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'items': '',
  'timestamp': '',
});

// Provider to manage the habit coaching data
final habitCoachingDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Provider to manage the scroll controller
final scrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// Provider to manage the task services
final taskServicesProvider = Provider<TaskServices>((ref) => TaskServices());

// Provider to manage the coaching service
final coachingServiceProvider = Provider<CoachingService>((ref) => CoachingService()); 