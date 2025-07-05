import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:nexttick/shared/models/task.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing local notifications and reminders
class NotificationService {

  NotificationService._();
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  /// Get singleton instance
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(final NotificationResponse response) {
    // Handle notification tap - can navigate to specific screens
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestExactAlarmsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Schedule notification for a calendar event
  Future<void> scheduleEventReminder({
    required final CalendarEvent event,
    required final Duration beforeEvent,
  }) async {
    final scheduledDate = event.startTime.subtract(beforeEvent);
    
    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming calendar events',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'event_reminder',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = event.id.hashCode;
    const title = 'Upcoming Event';
    final body = '${event.title} starts in ${_formatDuration(beforeEvent)}';

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      notificationDetails,
      payload: 'event:${event.id}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule notification for a task due date
  Future<void> scheduleTaskReminder({
    required final Task task,
    required final Duration beforeDue,
  }) async {
    if (task.dueDate == null) {
      return;
    }
    
    final scheduledDate = task.dueDate!.subtract(beforeDue);
    
    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming task due dates',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'task_reminder',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = task.id.hashCode;
    const title = 'Task Due Soon';
    final body = '${task.title} is due in ${_formatDuration(beforeDue)}';

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      notificationDetails,
      payload: 'task:${task.id}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule daily habit reminder
  Future<void> scheduleHabitReminder({
    required final String habitId,
    required final String habitName,
    required final TimeOfDay reminderTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for habits',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'habit_reminder',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = habitId.hashCode;
    const title = 'Habit Reminder';
    final body = 'Time for your $habitName habit!';

    // Schedule daily recurring notification
    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      _nextInstanceOfTime(reminderTime),
      notificationDetails,
      payload: 'habit:$habitId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show immediate notification
  Future<void> showNotification({
    required final String title,
    required final String body,
    final String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate',
      'Immediate Notifications',
      channelDescription: 'Immediate notifications',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(final int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() =>
      _notifications.pendingNotificationRequests();

  /// Convert DateTime to TZDateTime
  tz.TZDateTime _convertToTZDateTime(final DateTime dateTime) =>
      tz.TZDateTime.from(dateTime, tz.local);

  /// Get the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(final TimeOfDay time) {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      return _convertToTZDateTime(scheduledDate.add(const Duration(days: 1)));
    }
    
    return _convertToTZDateTime(scheduledDate);
  }

  /// Format duration for display
  String _formatDuration(final Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
    return 'a moment';
  }

  /// Schedule multiple event reminders with different timing
  Future<void> scheduleEventReminders(final CalendarEvent event) async {
    // Don't schedule for past events
    if (event.startTime.isBefore(DateTime.now())) {
      return;
    }

    // Schedule reminders at different intervals
    final reminderTimes = event.reminderMinutes ?? <int>[15];
    
    for (final minutes in reminderTimes) {
      await scheduleEventReminder(
        event: event,
        beforeEvent: Duration(minutes: minutes),
      );
    }
  }

  /// Schedule default task reminders
  Future<void> scheduleTaskReminders(final Task task) async {
    if (task.dueDate == null || task.dueDate!.isBefore(DateTime.now())) {
      return;
    }

    // Schedule reminders based on priority
    final List<Duration> reminderTimes;
    
    switch (task.priority) {
      case TaskPriority.urgent:
        reminderTimes = <Duration>[
          const Duration(days: 1),
          const Duration(hours: 4),
          const Duration(hours: 1),
        ];
      case TaskPriority.high:
        reminderTimes = <Duration>[
          const Duration(days: 1),
          const Duration(hours: 2),
        ];
      case TaskPriority.medium:
        reminderTimes = <Duration>[const Duration(hours: 4)];
      case TaskPriority.low:
        reminderTimes = <Duration>[const Duration(days: 1)];
    }

    for (final duration in reminderTimes) {
      await scheduleTaskReminder(
        task: task,
        beforeDue: duration,
      );
    }
  }
}
