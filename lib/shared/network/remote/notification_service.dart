import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _notificationTimer;

  Future<void> initNotification() async {
    try {
      debugPrint('=== Starting notification initialization ===');
      tz.initializeTimeZones();

      // Request notification permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        if (granted != true) {
          throw Exception('Notification permission not granted');
        }
      }

      AndroidInitializationSettings initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');

      var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      rethrow;
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'event_reminders',
        'Event Reminders',
        importance: Importance.max,
        priority: Priority.high,
        channelShowBadge: true,
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> scheduleEventNotification({
    required String eventId,
    required String eventName,
    required DateTime eventDateTime,
  }) async {
    try {
      // Cancel any existing timer
      _notificationTimer?.cancel();

      final now = DateTime.now();
      final notificationTime = eventDateTime.subtract(
        const Duration(minutes: 1),
      );

      // Check if event time is in the future
      if (eventDateTime.isBefore(now)) {
        throw Exception('Event time is in the past');
      }

      // Calculate time until notification
      final timeUntilNotification = notificationTime.difference(now);

      // Schedule the notification using a Timer
      _notificationTimer = Timer(timeUntilNotification, () async {
        try {
          await notificationsPlugin.show(
            eventId.hashCode,
            'Event Reminder',
            'Your event "$eventName" is starting in 1 minute!',
            notificationDetails(),
          );
        } catch (e) {
          debugPrint('Error showing notification: $e');
        }
      });
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelEventNotification(String eventId) async {
    try {
      _notificationTimer?.cancel();
      await notificationsPlugin.cancel(eventId.hashCode);
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
      rethrow;
    }
  }
}
