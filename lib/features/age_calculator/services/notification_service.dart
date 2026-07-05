import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? now,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _now = now ?? DateTime.now;

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _now;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: initializationSettings);

    const channel = AndroidNotificationChannel(
      'agely_reminders',
      'Agely Reminders',
      description: 'Saved date reminders from Agely.',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return true;
  }

  Future<void> syncReminders(List<Reminder> reminders) async {
    await initialize();
    await _plugin.cancelAll();

    if (reminders.isEmpty) {
      return;
    }

    final permissionsGranted = await requestPermissions();
    if (!permissionsGranted) {
      throw const NotificationPermissionDeniedException();
    }

    for (final reminder in reminders) {
      final nextTriggerDate = reminder.nextTriggerDate(_now());
      if (nextTriggerDate == null) {
        continue;
      }

      await _plugin.zonedSchedule(
        id: reminder.notificationId,
        title: reminder.title,
        body: _buildNotificationBody(reminder),
        scheduledDate: _toScheduledDate(nextTriggerDate),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'agely_reminders',
            'Agely Reminders',
            channelDescription: 'Saved date reminders from Agely.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.id,
      );
    }
  }

  String _buildNotificationBody(Reminder reminder) {
    final eventDate = DateFormat('d MMM y').format(reminder.targetDate);
    return '${reminder.category} - $eventDate';
  }

  tz.TZDateTime _toScheduledDate(DateTime date) {
    final now = tz.TZDateTime.from(_now(), tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      9,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = now.add(const Duration(minutes: 1));
    }

    return scheduledDate;
  }
}

class NotificationPermissionDeniedException implements Exception {
  const NotificationPermissionDeniedException();
}
