import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class Addrotinelistscreen extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  final List<Map<String, dynamic>> updateHabits;
  final String email;
  final VoidCallback onHabitUpdate;

  const Addrotinelistscreen({
    super.key,
    required this.habits,
    required this.updateHabits,
    required this.email,
    required this.onHabitUpdate,
  });

  @override
  State<Addrotinelistscreen> createState() => _AddRoutineListScreenState();
}

class _AddRoutineListScreenState extends State<Addrotinelistscreen> {
  int taskCount = 0; // Total habits added by the user
  List<Map<String, dynamic>> allHabits = []; // All habits from the database
  List<Map<String, dynamic>> sublist = []; // Habits added by the user
  late String safeEmail; // Safe email that's never empty

  @override
  void initState() {
    super.initState();
    // Ensure we have a valid email
    safeEmail = widget.email;
    fetchData(); // Fetch data on initialization
  }

  // Fetch all habits and user habits
  Future<void> fetchData() async {
    try {
      // Debug log
      final habits = await TaskServices().getHabits(); // Get all habits
      final userHabits =
          await TaskServices().getUserHabits(safeEmail); // Get user habits

      setState(() {
        allHabits = habits;
        sublist = userHabits;
        taskCount = userHabits.length; // Update task count
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  // Check if a habit is added by the user
  bool isHabitAdded(String habitId) {
    return sublist.any((habit) => habit['objectId'] == habitId);
  }

  // Toggle habit addition/removal
  void toggleHabit(String habitId) {
    // Debug log

    if (isHabitAdded(habitId)) {
      // Remove habit
      setState(() {
        sublist.removeWhere((habit) => habit['objectId'] == habitId);
        taskCount = sublist.length;
      });

      TaskServices().removeHabit(habitId, safeEmail).then((_) {
        widget.onHabitUpdate();
      }).catchError((error) {
        setState(() {
          sublist.add({'objectId': habitId});
          taskCount = sublist.length;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove habit: $error')),
        );
      });
    } else {
      // Add habit
      setState(() {
        sublist.add({'objectId': habitId});
        taskCount = sublist.length;
      });

      TaskServices().addHabits(safeEmail, habitId).then((_) {
        widget.onHabitUpdate();
      }).catchError((error) {
        setState(() {
          sublist.removeWhere((habit) => habit['objectId'] == habitId);
          taskCount = sublist.length;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add habit: $error')),
        );
      });
    }
  }

  // Convert string to color
  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {}
    return Colors.orange; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F2), // Light green background
      appBar: AppBar(
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.176,
                ),
                SvgPicture.asset(
                  'assets/icons/leaf.svg',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                Text(
                  '$taskCount Habits', // Displaying the updated habit count
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.alarm, size: 24, color: Colors.white),
                SizedBox(width: 20),
                Text("Healthy Routines",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 150,
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[800]!,
                    const Color.fromARGB(165, 67, 160, 72),
                    Colors.green[400]!,
                  ],
                ),
              ),
            ),
            // Decorative leaves
            Positioned(
              top: -20,
              right: -20,
              child: Transform.rotate(
                angle: -math.pi / 10,
                child: SvgPicture.asset(
                  'assets/icons/leaf.svg',
                  height: 100,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: Transform.rotate(
                angle: math.pi / 6,
                child: SvgPicture.asset(
                  'assets/icons/leaf.svg',
                  height: 70,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            // Overlay with slight transparency
            Container(
              color: Colors.black.withOpacity(0.1),
              width: double.infinity,
              height: double.infinity,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background leaf decorations
          Positioned(
            right: -30,
            top: 100,
            child: Transform.rotate(
              angle: math.pi / 15,
              child: SvgPicture.asset(
                'assets/icons/leaf.svg',
                height: 120,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 150,
            child: Transform.rotate(
              angle: -math.pi / 6,
              child: SvgPicture.asset(
                'assets/icons/leaf.svg',
                height: 150,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ),
          // Actual list content
          allHabits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Loading your habits...",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: allHabits.length,
                  itemBuilder: (context, index) {
                    final habit = allHabits[index];
                    final habitId = habit['objectId'];
                    final iconPath = habit['iconUrl'] ?? '';
                    final isAdded = isHabitAdded(habitId);
                    final Color itemColor =
                        isAdded ? colorFromString(habit['color']) : Colors.grey;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isAdded
                                ? Colors.green.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: itemColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: SvgPicture.network(
                                        iconPath,
                                        width: 24,
                                        height: 24,
                                        color: itemColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        habit['name'] ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Custom button
                              InkWell(
                                onTap: () => toggleHabit(habitId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isAdded
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isAdded
                                          ? Colors.red.withOpacity(0.5)
                                          : Colors.green.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAdded
                                            ? Icons.remove_circle_outline
                                            : Icons.add_circle_outline,
                                        size: 16,
                                        color:
                                            isAdded ? Colors.red : Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAdded ? 'REMOVE' : 'ADD',
                                        style: TextStyle(
                                          color: isAdded
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
