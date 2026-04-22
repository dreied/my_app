// utils/date_format.dart

String formatDateTimeUI(String raw) {
  final dt = DateTime.parse(raw);

  final date =
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  final hour = dt.hour == 0
      ? 12
      : dt.hour > 12
          ? dt.hour - 12
          : dt.hour;

  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? "PM" : "AM";

  return "Date: $date   Time: $hour:$minute $ampm";
}

String formatDateTimeReceipt(String raw) {
  final dt = DateTime.parse(raw);

  final date =
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  final hour = dt.hour == 0
      ? 12
      : dt.hour > 12
          ? dt.hour - 12
          : dt.hour;

  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? "PM" : "AM";

  return "$date  $hour:$minute $ampm";
}
