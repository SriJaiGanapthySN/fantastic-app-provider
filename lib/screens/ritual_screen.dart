import 'package:fantastic_app_riverpod/utils/blur_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/background_video.dart';
import '../widgets/alarm_widget.dart';
import '../widgets/habit_list.dart';
import '../providers/_providers.dart';
import '../services/task_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for TaskServices
final taskServicesProvider = Provider<TaskServices>((ref) => TaskServices());

// Provider for user email (replace with actual user email from auth)
final userEmailProvider = Provider<String>((ref) => 'test@example.com'); // Replace with actual user email

// Provider for daily tasks stream
final dailyTasksStreamProvider = StreamProvider.family<QuerySnapshot, String>((ref, email) {
  final taskServices = ref.watch(taskServicesProvider);
  return taskServices.getdailyTasks(email);
});

class RitualScreen extends ConsumerWidget {
  const RitualScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEmail = ref.watch(userEmailProvider);
    final tasksAsyncValue = ref.watch(dailyTasksStreamProvider(userEmail));

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
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(
                            task['name'] ?? 'Unnamed Task',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            task['descriptionHtml'] ?? 'No description',
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                          trailing: Checkbox(
                            value: task['iscompleted'] ?? false,
                            onChanged: (bool? value) {
                              if (value != null) {
                                ref.read(taskServicesProvider).updateTaskStatus(
                                  value,
                                  task['objectID'],
                                  userEmail,
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 112.0, left: 16, right: 16),
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
                    BlurContainer(
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
