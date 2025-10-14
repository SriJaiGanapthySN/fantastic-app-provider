import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateState extends StateNotifier<DateTime> {
  DateState() : super(_normalizeDate(DateTime.now()));

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get today => _normalizeDate(DateTime.now());

  void setDate(int index) {
    final difference = index - 3;
    state = today.add(Duration(days: difference));
  }

  String get formattedDay {
    final difference = state.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE').format(state);
    }
  }

  String getFormattedDate() {
    final difference = state.difference(today).inDays;

    if (difference >= -1 && difference <= 1) {
      String prefix = formattedDay;
      String dayAndMonth = DateFormat('E, d MMM').format(state);

      dayAndMonth = dayAndMonth.replaceAllMapped(
          RegExp(r' ([A-Za-z]+)$'), (match) => ' ${match.group(1)!}');

      return '$prefix . $dayAndMonth';
    } else {
      String dayAndMonth = DateFormat('E, d MMM').format(state);

      dayAndMonth = dayAndMonth.replaceAllMapped(
          RegExp(r' ([A-Za-z]+)$'), (match) => ' ${match.group(1)!}');

      return dayAndMonth;
    }
  }

  String getCurrentDay() {
    return DateFormat('EEEE').format(today);
  }

  String getNextDayText() {
    final nextDay = state.add(const Duration(days: 1));
    return DateFormat('EEEE').format(nextDay);
  }

  String getPreviousDayText() {
    final previousDay = state.subtract(const Duration(days: 1));
    return DateFormat('EEEE').format(previousDay);
  }
}
