import 'package:fantastic_app_riverpod/services/task_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    print('AddRoutineListScreen: Using email: $safeEmail');
    fetchData(); // Fetch data on initialization
  }

  // Fetch all habits and user habits
  Future<void> fetchData() async {
    try {
      print('Fetching habits for email: $safeEmail'); // Debug log
      final habits = await TaskServices().getHabits(); // Get all habits
      final userHabits =
          await TaskServices().getUserHabits(safeEmail); // Get user habits

      setState(() {
        allHabits = habits;
        sublist = userHabits;
        taskCount = userHabits.length; // Update task count
      });
    } catch (e) {
      print('Error fetching data: $e');
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
    print('Toggle habit $habitId for email: $safeEmail'); // Debug log

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
    } catch (e) {
      print("Invalid color string: $e");
    }
    return Colors.orange; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(
                  Icons.dashboard_sharp,
                  color: Colors.white,
                ),
                const SizedBox(width: 40),
                Text(
                  '$taskCount habits', // Displaying the updated habit count
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.alarm, size: 32, color: Colors.white),
                SizedBox(width: 40),
                Text("None",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ],
        ),
        toolbarHeight: 166,
        flexibleSpace: Stack(
          children: [
            const Image(
              image: AssetImage('assets/images/image.png'),
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              width: double.infinity,
              height: double.infinity,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: allHabits.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allHabits.length,
              itemBuilder: (context, index) {
                final habit = allHabits[index];
                final habitId = habit['objectId'];
                final iconPath = habit['iconUrl'] ?? '';
                final isAdded = isHabitAdded(habitId);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.network(
                              iconPath,
                              width: 24,
                              height: 24,
                              color: isAdded
                                  ? colorFromString(habit['color'])
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 20),
                            // Text(habit['name']),
                            Expanded(
                              child: Text(
                                habit['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            // Expanded(
                            //     child: Text(habit['name'],
                            //         textAlign: TextAlign.start)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => toggleHabit(habitId),
                        child: Text(
                          isAdded ? 'REMOVE' : 'ADD',
                          style: TextStyle(
                            color: isAdded ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
