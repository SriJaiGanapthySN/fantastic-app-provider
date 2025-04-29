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

// Provider for TaskServices
final taskServicesProvider = Provider<TaskServices>((ref) => TaskServices());

// Hardcoded email ID
final userEmailProvider = Provider<String>((ref) => "03@gmail.com");

// Provider for daily tasks stream
final dailyTasksStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, email) {
  final taskServices = ref.watch(taskServicesProvider);
  return taskServices.getdailyTasks(email);
});

class RitualScreen extends ConsumerWidget {
  const RitualScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEmail = ref.watch(userEmailProvider);
    final tasksAsyncValue = ref.watch(dailyTasksStreamProvider(userEmail));
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
              const HabitList(),
              Expanded(
                child: tasksAsyncValue.when(
                  data: (snapshot) {
                    final tasks = snapshot.docs;
                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tasks available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    // Update task data in provider
                    if (currentTaskIndex < tasks.length) {
                      final currentTask = tasks[currentTaskIndex].data()
                          as Map<String, dynamic>;
                      ref.read(taskDataProvider.notifier).state = currentTask;
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task =
                            tasks[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(
                            task['name'] ?? 'Unnamed Task',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            task['descriptionHtml'] ?? 'No description',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                          trailing: Checkbox(
                            value: task['iscompleted'] ?? false,
                            onChanged: (bool? value) {
                              if (value != null) {
                                // First update the task status
                                ref.read(taskServicesProvider).updateTaskStatus(
                                      value,
                                      task['objectID'],
                                      userEmail,
                                    );

                                // Set current task index to this task
                                ref
                                    .read(currentTaskIndexProvider.notifier)
                                    .state = index;

                                // Store task data in provider
                                ref.read(taskDataProvider.notifier).state =
                                    task;

                                // Navigate to TaskReveal
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Taskreveal(
                                      email: userEmail,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => habitPlay(
                              email: userEmail,
                            ),
                          ),
                        );
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
