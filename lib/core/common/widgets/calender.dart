import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});
  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now(); // Focused day
  DateTime _selectedDay = DateTime.now(); // Selected day

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Your Streak',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        Container(
          height: 276,
          width: 300,
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(_focusedDay.year, _focusedDay.month, 1),
            lastDay: DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerVisible: false,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false, // Remove format button
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors
                    .transparent, // Hide weekday names (Monday, Tuesday, etc.)
              ),
              weekendStyle: TextStyle(
                color: Colors.transparent, // Hide weekend names
              ),
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.yellow[600],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
