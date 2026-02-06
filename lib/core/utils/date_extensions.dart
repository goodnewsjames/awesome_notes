import 'package:intl/intl.dart';

/// Very short: 05/02/26 or 05 Feb 26 (depending on locale)
String formatShortDate(
  DateTime dateTime, {
  String? pattern,
}) {
  final format = pattern ?? "dd MMM, y";
  return DateFormat(format).format(dateTime);
}

/// Standard note app style: 5 February 2026, 8:49 AM
String formatLongDate(
  DateTime dateTime, {
  String? pattern,
}) {
  final format = pattern ?? "dd MMMM y, hh:mm a";
  return DateFormat(format).format(dateTime);
}

/// Relative time (today, yesterday, 3 days ago, etc.)
/// Useful for lists like Google Keep / Apple Notes
String formatRelativeDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    return "Today";
  } else if (difference.inDays == 1) {
    return "Yesterday";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} days ago";
  } else {
    // Fallback to short date for older notes
    return DateFormat("dd MMM, y").format(dateTime);
  }
}

/// Very compact: just time if today, otherwise short date
String formatSmartDate(DateTime dateTime) {
  final now = DateTime.now();
  final isToday =
      dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  if (isToday) {
    return DateFormat("hh:mm a").format(dateTime);
  } else {
    return DateFormat("dd MMM, y").format(dateTime);
  }
}
