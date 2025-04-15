import 'package:fantastic_app_riverpod/screens/ritual/addrotinelistscreen.dart';
// import 'package:fab/screens/ADDR.dart';
import 'package:flutter/material.dart';

class Routinelistheader extends StatefulWidget {
  final int number;
  final List<Map<String, dynamic>> habits;
  final List<Map<String, dynamic>> updateHabits;
  final String email;
  final VoidCallback onHabitChanged;

  const Routinelistheader(
      {super.key,
      required this.number,
      required this.habits,
      required this.updateHabits,
      required this.email,
      required this.onHabitChanged});

  @override
  State<Routinelistheader> createState() => _RoutinelistheaderState();
}

class _RoutinelistheaderState extends State<Routinelistheader> {
  void habitUpdate() {
    widget.onHabitChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_left,
                  color: Colors.red,
                  size: 34,
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              const Column(
                children: [Text('habits'), Text('Today')],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Addrotinelistscreen(
                          habits: widget.habits,
                          updateHabits: widget.updateHabits,
                          email: widget.email,
                          onHabitUpdate: widget.onHabitChanged),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
        ],
      ),
    );
  }
}
