// import 'package:fantastic_app_riverpod/screens/ritual/habitPlay.dart';
// import 'package:fantastic_app_riverpod/services/task_services.dart';
// import 'package:fantastic_app_riverpod/widgets/rituals/routinelistheader.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class Routinelistscreen extends StatefulWidget {
//   final String email;

//   const Routinelistscreen({super.key, required this.email});

//   @override
//   State<Routinelistscreen> createState() => _RoutinelistscreenState();
// }

// class _RoutinelistscreenState extends State<Routinelistscreen> {
//   List<Map<String, dynamic>> _habits = [];
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   final bool _isAnimating = false;

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     TaskServices().getUserHabits(widget.email).then((userHabits) {
//       setState(() {
//         _habits = userHabits;
//       });
//     });
//   }

//   Future<void> _loadHabits() async {
//     final userHabits = await TaskServices().getUserHabits(widget.email);
//     setState(() {
//       _habits = userHabits;
//     });
//   }
//   // void _updateHabits(List<String> updatedHabits) {
//   //   setState(() {
//   //     _habits = updatedHabits;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Wake Up Routine',
//               style: TextStyle(fontSize: 25, color: Colors.white),
//             ),
//             const SizedBox(height: 70),
//             Row(
//               children: [
//                 const Opacity(
//                   opacity: 0.5,
//                   child: Icon(
//                     Icons.alarm,
//                     size: 32,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(width: 40),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Alarm',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                     GestureDetector(
//                       onTap: () => _selectTime(context),
//                       child: Text(
//                         _selectedTime.format(context),
//                         style:
//                             const TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//         toolbarHeight: 166,
//         flexibleSpace: Stack(
//           children: [
//             const Image(
//               image: AssetImage('assets/images/RoutinesList.png'),
//               width: double.infinity,
//               fit: BoxFit.fill,
//             ),
//             Container(
//               color: Colors.black.withOpacity(0.2),
//               width: double.infinity,
//               height: double.infinity,
//             ),
//           ],
//         ),
//         backgroundColor: Colors.transparent,
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 Routinelistheader(
//                   number: _habits.length,
//                   updateHabits: _habits,
//                   habits: _habits,
//                   email: widget.email,
//                   onHabitChanged: _loadHabits,
//                 ),
//                 const Divider(),
//                 Expanded(
//                   child: Routinelist(
//                     habit: _habits,
//                     email: widget.email,
//                   ),
//                 ),
//               ],
//             ),
//             if (_isAnimating)
//               Positioned(
//                 bottom: 20,
//                 right: 20,
//                 child: Lottie.asset(
//                   'assets/animations/water.json',
//                   width: 200,
//                   height: 200,
//                   repeat: false,
//                 ),
//               ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             // MaterialPageRoute(builder: (context) => Taskreveal(email: widget.email)),
//             MaterialPageRoute(
//                 builder: (context) => habitPlay(email: widget.email)),
//           );
//         },
//         label: const Text('Play', style: TextStyle(color: Colors.white)),
//         icon: const Icon(Icons.rocket, color: Colors.white),
//         backgroundColor: const Color.fromARGB(255, 143, 110, 239),
//       ),
//     );
//   }
// }
