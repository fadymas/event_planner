import 'package:event_planner/models/Events.dart';
import 'package:event_planner/shared/network/remote/notification_service.dart';

class EventNotificationHandler {
  static final EventNotificationHandler _instance =
      EventNotificationHandler._internal();
  factory EventNotificationHandler() => _instance;
  EventNotificationHandler._internal();

  final NotificationService _notificationService = NotificationService();

  Future<void> scheduleEventNotification(EventModel event) async {
    // Parse event date and time
    final eventDate = DateTime.parse(event.date);
    final timeParts = event.time.split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);

    if (event.time.toLowerCase().contains('pm') && hour != 12) {
      hour += 12;
    } else if (event.time.toLowerCase().contains('am') && hour == 12) {
      hour = 0;
    }

    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      hour,
      minute,
    );

    // Schedule notification 1 minute before the event
    await _notificationService.scheduleEventNotification(
      eventId: event.id,
      eventName: event.name,
      eventDateTime: eventDateTime,
    );
  }

  Future<void> cancelEventNotification(String eventId) async {
    await _notificationService.cancelEventNotification(eventId);
  }
}
