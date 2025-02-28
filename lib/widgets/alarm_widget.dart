import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/_providers.dart';
import '../utils/blur_container.dart';

class AlarmWidget extends ConsumerWidget {
  const AlarmWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmState = ref.watch(alarmProvider);

    final alarmColor = alarmState.isAlarmSet
        ? const Color(0xFF00E29A)
        : const Color(0xFFFCC500);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 58.0),
      child: BlurContainer(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        borderRadius: 24,
        color: Colors.black.withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: BlurContainer(
                borderRadius: 12,
                blur: 44,
                enableGlow: true,
                glowColor: alarmColor,
                glowSpread: 44,
                glowIntensity: 0.9,
                padding: const EdgeInsets.all(16),
                color: alarmColor,
                child: InkWell(
                  onTap: () {
                    ref.read(alarmProvider.notifier).toggleAlarm();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alarm',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          Text(
                            alarmState.alarmTime,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlurContainer(
                borderRadius: 12,
                blur: 44,
                padding: const EdgeInsets.all(16),
                color: Colors.black.withValues(alpha: 0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        Text(
                          '11 Min',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
