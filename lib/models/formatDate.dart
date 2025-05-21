abstract class FormatDate {
  static String formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.month}/${dateTime.day}/${dateTime.year.toString().substring(2)}';
  }
}
