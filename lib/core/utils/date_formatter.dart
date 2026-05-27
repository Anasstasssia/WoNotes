import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  static String formatDate(DateTime dt) =>
      DateFormat('dd.MM.yyyy').format(dt);

  static String formatDateLong(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) {
      return 'СЕГОДНЯ, ${DateFormat('dd.MM.yyyy').format(dt)}';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) {
      return 'ВЧЕРА, ${DateFormat('dd.MM.yyyy').format(dt)}';
    }
    return DateFormat('dd.MM.yyyy').format(dt).toUpperCase();
  }

  static String formatMonthYear(DateTime dt) =>
      DateFormat('MMMM yyyy', 'ru').format(dt);

  static String formatMonthDay(DateTime dt) =>
      DateFormat('d MMMM', 'ru').format(dt);

  static String formatDayOfWeek(DateTime dt) =>
      DateFormat('EEEE', 'ru').format(dt);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime normalize(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
