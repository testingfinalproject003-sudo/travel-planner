import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final timeOfDay = DateTime(2026, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('hh:mm a').format(timeOfDay);
    } catch (_) {
      return timeStr;
    }
  }

  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }
}