import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/background_video.dart';
import '../widgets/alarm_widget.dart';
import '../widgets/habit_list.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/_providers.dart';

class RitualScreen extends ConsumerWidget {
  const RitualScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  ref.read(videoProvider.notifier).switchVideo();
                } else if (details.primaryVelocity! > 0) {
                  ref.read(videoProvider.notifier).switchVideo();
                }
              }
            },
            child: const BackgroundVideo(),
          ),
          SafeArea(
            child: Column(
              children: const [
                SizedBox(height: 64),
                AlarmWidget(),
                HabitList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const BottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
