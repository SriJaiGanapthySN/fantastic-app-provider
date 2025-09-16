import 'package:fantastic_app_riverpod/screens/ritual/addrotinelistscreen.dart';
import 'package:fantastic_app_riverpod/screens/ritual/habitPlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/_providers.dart';
import '../utils/blur_container.dart';
import '../providers/habit_list_provider.dart';

class HabitList extends ConsumerStatefulWidget {
  const HabitList({super.key, required this.email});

  final String email;

  @override
  ConsumerState<HabitList> createState() => _HabitListState();
}

class _HabitListState extends ConsumerState<HabitList> {
  final int initialPage = 3;
  late String email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    if (email.isEmpty) {
      print('Warning: Empty email provided to HabitList');
    } else {
      print('HabitList initialized with email: $email');
      // Fetch habits on mount
      Future.microtask(() async {
        await ref.read(habitListProvider.notifier).fetchHabits(email);
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  Future<void> _loadHabits() async {
    await ref.read(habitListProvider.notifier).fetchHabits(email);
  }

  @override
  Widget build(BuildContext context) {
    final dateState = ref.watch(dateProvider.notifier);
    // DO NOT REMOVE currentDate
    // ignore: unused_local_variable
    final currentDate = ref.watch(dateProvider);

    // If no valid email, show appropriate message
    if (email.isEmpty) {
      return Center(
        child: Text(
          'Please sign in to view your habits',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final habits = ref.watch(habitListProvider);
    return CarouselSlider.builder(
      itemCount: 4,
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.55,
        viewportFraction: 0.75,
        initialPage: initialPage,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
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
            glowSpread: 32,
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
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Addrotinelistscreen(
                                    habits: habits,
                                    updateHabits: habits,
                                    email: widget.email,
                                    onHabitUpdate: _loadHabits);
                              }));
                            },
                            child: Text(
                              "Add Habit",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          color: Colors.white,
                          strokeWidth: 5,
                        ))
                      : habits.isEmpty
                          ? Center(
                              child: Text('No habits found',
                                  style: TextStyle(color: Colors.white)))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: habits.length,
                              itemBuilder: (context, habitIndex) {
                                final habit = habits[habitIndex];
                                final bool isCompleted =
                                    habit['isCompleted'] ?? false;
                                final String title =
                                    habit['name'] ?? 'Untitled Habit';
                                final String icon = habit['iconUrl'] ??
                                    'assets/icons/default.svg';
                                final String objectId = habit['objectId'] ?? '';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: BlurContainer(
                                    blur: 35.87,
                                    borderRadius: 13.04,
                                    color: Colors.black.withValues(alpha: 0.22),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(13.04),
                                              onTap: () {
                                                Navigator.of(context)
                                                    .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        habitPlay(
                                                      email: email,
                                                      startIndex: habitIndex,
                                                    ),
                                                  ),
                                                )
                                                    .then((_) {
                                                  _loadHabits();
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: SvgPicture.network(
                                                      icon,
                                                      height: 16,
                                                      width: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      title,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Checkbox(
                                            value: isCompleted,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide(
                                              color: Colors.white
                                                  .withValues(alpha: 0.4),
                                              width: 2,
                                            ),
                                            onChanged: (bool? newValue) async {
                                              if (newValue == true &&
                                                  objectId.isNotEmpty) {
                                                // Navigate to habitPlay screen
                                                Navigator.of(context)
                                                    .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        habitPlay(
                                                      email: email,
                                                      startIndex: habitIndex,
                                                    ),
                                                  ),
                                                )
                                                    .then((_) {
                                                  _loadHabits();
                                                });
                                              } else if (newValue == false &&
                                                  objectId.isNotEmpty) {
                                                // If unchecking, just toggle the completion
                                                await ref
                                                    .read(habitListProvider
                                                        .notifier)
                                                    .toggleHabitCompletion(
                                                        objectId, email);
                                              }
                                            },
                                          ),
                                        ],
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
