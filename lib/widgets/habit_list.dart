import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/_providers.dart';
import '../utils/blur_container.dart';

class HabitList extends ConsumerStatefulWidget {
  const HabitList({super.key});

  @override
  ConsumerState<HabitList> createState() => _HabitListState();
}

class _HabitListState extends ConsumerState<HabitList> {
  final int initialPage = 3;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final dateState = ref.watch(dateProvider.notifier);
    final currentDate = ref.watch(dateProvider);

    return CarouselSlider.builder(
      itemCount: 7,
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.61,
        viewportFraction: 0.75,
        initialPage: initialPage,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        enlargeFactor: 0.35,
        onPageChanged: (index, reason) {
          dateState.setDate(index);
        },
      ),
      itemBuilder: (context, index, realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: BlurContainer(
            borderRadius: 19.56,
            blur: 35.87,
            glowColor: Colors.white,
            glowSpread: 54,
            glowIntensity: 0.69,
            enableGlow: true,
            color: Colors.black.withValues(alpha: 0.22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(19.56)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chevron_left,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${habits.length} Habits',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                dateState.getFormattedDate(),
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            dateState.getNextDayText(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: habits.length,
                    itemBuilder: (context, habitIndex) {
                      final habit = habits[habitIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: BlurContainer(
                          blur: 35.87,
                          borderRadius: 13.04,
                          color: Colors.black.withValues(alpha: 0.22),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(habitsProvider.notifier)
                                  .toggleHabit(habit.id);
                            },
                            borderRadius: BorderRadius.circular(13.04),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: SvgPicture.asset(
                                      habit.icon,
                                      height: 16,
                                      width: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      habit.title,
                                      style: TextStyle(
                                        decoration: habit.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: habit.isCompleted
                                            ? Colors.grey
                                            : Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                    value: habit.isCompleted,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                    onChanged: (_) {
                                      ref
                                          .read(habitsProvider.notifier)
                                          .toggleHabit(habit.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
