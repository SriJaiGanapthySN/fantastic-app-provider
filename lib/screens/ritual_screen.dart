import 'package:fantastic_app_riverpod/utils/blur_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/background_video.dart';
import '../widgets/alarm_widget.dart';
import '../widgets/habit_list.dart';
import '../providers/_providers.dart';

class RitualScreen extends ConsumerWidget {
  const RitualScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Spacer(),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 112.0, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlurContainer(
                      borderRadius: 74,
                      blur: 16,
                      color: Colors.white.withValues(alpha: .16),
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icons/stars.svg',
                      ),
                    ),
                    BlurContainer(
                      borderRadius: 74,
                      blur: 16,
                      color: Color(0xff9747FF),
                      enableGlow: true,
                      glowColor: Color(0xff9747FF),
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
