import 'package:fantastic_app_riverpod/screens/ritual/addrotinelistscreen.dart';
import 'package:fantastic_app_riverpod/screens/ritual/habitPlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/_providers.dart';
import '../utils/blur_container.dart';
import '../services/task_services.dart';

class HabitList extends ConsumerStatefulWidget {
  const HabitList({super.key, required this.email});

  final String email;

  @override
  ConsumerState<HabitList> createState() => _HabitListState();
}

class _HabitListState extends ConsumerState<HabitList> {
  final int initialPage = 3;
  final TaskServices _taskServices = TaskServices();
  List<Map<String, dynamic>> _habits = [];
  bool _isLoading = true;
  late String email;

  @override
  void initState() {
    super.initState();
    email = widget.email;

    if (email.isEmpty) {
      print('Warning: Empty email provided to HabitList');
      // Consider adding a fallback behavior here
    } else {
      print('HabitList initialized with email: $email');
    }

    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    try {
      if (email.isEmpty) {
        setState(() {
          _habits = [];
          _isLoading = false;
        });
        return;
      }

      final habits = await _taskServices.getUserHabits(email);
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching habits: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHabits() async {
    final userHabits = await TaskServices().getUserHabits(email);
    setState(() {
      _habits = userHabits;
    });
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

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CarouselSlider.builder(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(19.56)),
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
                                      '${_habits.length} Habits',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      dateState.getFormattedDate(),
                                      style: TextStyle(
                                        color:
                                            Colors.black.withValues(alpha: 0.6),
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
                                          habits: _habits,
                                          updateHabits: _habits,
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
                                // Text(
                                //   dateState.getCurrentDay(),
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.w600,
                                //     fontSize: 12,
                                //   ),
                                // ),
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
                        child: _habits.isEmpty
                            ? Center(
                                child: Text('No habits found',
                                    style: TextStyle(color: Colors.white)))
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _habits.length,
                                itemBuilder: (context, habitIndex) {
                                  final habit = _habits[habitIndex];
                                  final bool isCompleted =
                                      habit['isCompleted'] ?? false;
                                  final String title =
                                      habit['name'] ?? 'Untitled Habit';
                                  final String icon = habit['iconUrl'] ??
                                      'assets/icons/default.svg';
                                  final String objectId =
                                      habit['objectId'] ?? '';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: BlurContainer(
                                      blur: 35.87,
                                      borderRadius: 13.04,
                                      color:
                                          Colors.black.withValues(alpha: 0.22),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 8.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
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
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
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
                                              onChanged:
                                                  (bool? newValue) async {
                                                if (newValue != null) {
                                                  if (!isCompleted) {
                                                    // Navigate to habitPlay with the specific habit index
                                                    Navigator.of(context)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            habitPlay(
                                                          email:
                                                              email, // Use safe email
                                                          startIndex:
                                                              habitIndex, // Pass the specific habit index
                                                        ),
                                                      ),
                                                    )
                                                        .then((_) {
                                                      // Refresh habits when returning
                                                      _fetchHabits();
                                                    });
                                                  } else {
                                                    // If already completed, just update status to incomplete
                                                    await _taskServices
                                                        .updateHabitStatus(
                                                            false,
                                                            objectId,
                                                            email); // Use safe email
                                                    _fetchHabits();
                                                  }
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
