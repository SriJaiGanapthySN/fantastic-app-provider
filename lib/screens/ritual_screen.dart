import 'package:fantastic_app_riverpod/screens/auth_page.dart';
import 'package:fantastic_app_riverpod/screens/ritual/addrotinelistscreen.dart';
import 'package:fantastic_app_riverpod/utils/blur_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/background_video.dart';
import '../widgets/alarm_widget.dart';
import '../widgets/habit_list.dart';
import '../providers/_providers.dart';
import '../providers/habit_play_provider.dart';
import '../services/task_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ritual/taskreveal.dart';
import 'ritual/habitPlay.dart';
import '../providers/auth_provider.dart';

// Provider for TaskServices
final taskServicesProvider = Provider<TaskServices>((ref) => TaskServices());

// Provider for daily tasks stream
final dailyTasksStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, email) {
  final taskServices = ref.watch(taskServicesProvider);
  return taskServices.getdailyTasks(email);
});

class RitualScreen extends ConsumerWidget {
  const RitualScreen({super.key, required this.currentUserEmail});

  final String currentUserEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current authenticated user's email
    final authState = ref.watch(authProvider);
    final providedEmail = ref.watch(userEmailProvider);

    // Use the most up-to-date email source with validation
    String email = '';

    // First check auth state for current user
    if (authState.user?.email != null && authState.user!.email!.isNotEmpty) {
      email = authState.user!.email!;
    }
    // Then try passed email parameter
    else if (currentUserEmail.isNotEmpty) {
      email = currentUserEmail;
    }
    // Finally fall back to provider email
    else if (providedEmail.isNotEmpty) {
      email = providedEmail;
    }

    print('RitualScreen using email: $email');

    // If no valid email is available, show appropriate UI
    if (email.isEmpty) {
      print('No valid email available in RitualScreen');
      // Consider showing a message or redirecting to login
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please sign in to access your rituals'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const AuthPage();
                }));
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      );
    }

    // Create a unique cache key that combines the email with a timestamp
    // This helps prevent caching issues when switching users
    final cacheKey = "$email-${DateTime.now().millisecondsSinceEpoch}";

    // Use the cache key with the dailyTasksStreamProvider
    final tasksAsyncValue = ref.watch(dailyTasksStreamProvider(email));

    final currentTaskIndex = ref.watch(currentTaskIndexProvider);
    final isTaskSnoozed = ref.watch(isTaskSnoozedProvider);
    final isTaskSkipped = ref.watch(isTaskSkippedProvider);
    final audioState = ref.watch(audioStateProvider);
    final taskData = ref.watch(taskDataProvider);
    final notesData = ref.watch(notesDataProvider);
    final habitCoachingData = ref.watch(habitCoachingDataProvider);
    final scrollController = ref.watch(scrollControllerProvider);

    return Stack(
      children: [
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                ref.read(videoProvider.notifier).nextVideo();
              } else if (details.primaryVelocity! > 0) {
                ref.read(videoProvider.notifier).previousVideo();
              }
            }
          },
          child: const BackgroundVideo(),
        ),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 64),
              const AlarmWidget(),
              HabitList(
                email: email, // Use the validated email
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 112.0, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlurContainer(
                      borderRadius: 74,
                      blur: 16,
                      color: Colors.white.withOpacity(0.16),
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icons/stars.svg',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Get the list of habits first
                        TaskServices()
                            .getUserHabits(email) // Use validated email
                            .then((habits) {
                          int firstUncompletedIndex = -1;

                          // Find the first uncompleted habit
                          for (int i = 0; i < habits.length; i++) {
                            if (habits[i]['isCompleted'] == false) {
                              firstUncompletedIndex = i;
                              break;
                            }
                          }

                          // If all habits are completed, start from the beginning
                          // Otherwise start with the first uncompleted habit
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => habitPlay(
                                email: email, // Use validated email
                                startIndex: firstUncompletedIndex >= 0
                                    ? firstUncompletedIndex
                                    : 0,
                              ),
                            ),
                          );
                        });
                      },
                      child: BlurContainer(
                        borderRadius: 74,
                        blur: 16,
                        color: const Color(0xff9747FF),
                        enableGlow: true,
                        glowColor: const Color(0xff9747FF),
                        glowSpread: 24,
                        glowIntensity: 0.9,
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          'assets/icons/play.svg',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
