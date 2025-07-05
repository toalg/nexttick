import 'package:flutter/material.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:nexttick/shared/models/habit.dart';
import 'package:nexttick/shared/models/task.dart';
import 'package:nexttick/shared/services/database_service.dart';

/// Service for managing calendar events
class CalendarService {
  CalendarService._();
  static CalendarService? _instance;
  late DatabaseService _database;
  final List<CalendarEvent> _events = [];

  /// Get singleton instance
  static CalendarService get instance {
    _instance ??= CalendarService._();
    return _instance!;
  }

  /// Get all events
  List<CalendarEvent> get events => List.unmodifiable(_events);

  /// Initialize service and load events
  Future<void> initialize() async {
    _database = DatabaseService.instance;
    await _database.initialize();

    // Load existing events from database
    final eventsData = await _database.getCalendarEvents();
    _events.addAll(eventsData.map((data) => CalendarEvent.fromMap(data)));
  }

  /// Add a new calendar event
  Future<void> addEvent(final CalendarEvent event) async {
    _events.add(event);
    await _database.insertCalendarEvent(event.toMap());
  }

  /// Update an existing calendar event
  Future<void> updateEvent(final CalendarEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _database.updateCalendarEvent(event.toMap());
    }
  }

  /// Delete a calendar event
  Future<void> deleteEvent(final String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
    await _database.deleteCalendarEvent(eventId);
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDate(final DateTime date) =>
      _events.where((final event) {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        final checkDate = DateTime(date.year, date.month, date.day);
        return eventDate.isAtSameMomentAs(checkDate);
      }).toList();

  /// Get events for a date range
  List<CalendarEvent> getEventsForDateRange({
    required final DateTime startDate,
    required final DateTime endDate,
  }) => _events
      .where(
        (final event) =>
            event.startTime.isAfter(startDate) &&
            event.startTime.isBefore(endDate),
      )
      .toList();

  /// Get events by category
  List<CalendarEvent> getEventsByCategory(final EventCategory category) =>
      _events.where((final event) => event.category == category).toList();

  /// Get upcoming events (next 7 days)
  List<CalendarEvent> getUpcomingEvents() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return _events
        .where(
          (final event) =>
              event.startTime.isAfter(now) &&
              event.startTime.isBefore(weekFromNow),
        )
        .toList();
  }

  /// Get conflicting events for a time slot
  List<CalendarEvent> getConflictingEvents({
    required final DateTime startTime,
    required final DateTime endTime,
    final String? excludeEventId,
  }) => _events.where((final event) {
    if (excludeEventId != null && event.id == excludeEventId) {
      return false;
    }
    return startTime.isBefore(event.endTime) &&
        endTime.isAfter(event.startTime);
  }).toList();

  /// Move an event to a new time
  Future<void> moveEvent(
    final String eventId,
    final DateTime newStartTime,
    final DateTime newEndTime,
  ) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    final updatedEvent = event.copyWith(
      startTime: newStartTime,
      endTime: newEndTime,
    );
    await updateEvent(updatedEvent);
  }

  /// Mark an event as completed
  Future<void> completeEvent(final String eventId) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    final updatedEvent = event.copyWith(isCompleted: true);
    await updateEvent(updatedEvent);
  }

  /// Generate recurring events
  Future<List<CalendarEvent>> generateRecurringEvents({
    required final CalendarEvent baseEvent,
    required final DateTime endDate,
  }) async {
    final generatedEvents = <CalendarEvent>[];

    if (baseEvent.recurrenceType == RecurrenceType.none) {
      return generatedEvents;
    }

    DateTime currentDate = baseEvent.startTime;

    while (currentDate.isBefore(endDate)) {
      switch (baseEvent.recurrenceType) {
        case RecurrenceType.daily:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case RecurrenceType.monthly:
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        case RecurrenceType.yearly:
          currentDate = DateTime(
            currentDate.year + 1,
            currentDate.month,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        case RecurrenceType.none:
        case RecurrenceType.custom:
          break;
      }

      if (currentDate.isBefore(endDate)) {
        final duration = baseEvent.duration;
        final newEvent = CalendarEvent.create(
          title: baseEvent.title,
          startTime: currentDate,
          endTime: currentDate.add(duration),
          description: baseEvent.description,
          category: baseEvent.category,
          priority: baseEvent.priority,
          color: baseEvent.color,
          isAllDay: baseEvent.isAllDay,
          location: baseEvent.location,
          notes: baseEvent.notes,
          taskId: baseEvent.taskId,
          habitId: baseEvent.habitId,
        );

        generatedEvents.add(newEvent);
        _events.add(newEvent);
      }
    }

    return generatedEvents;
  }

  /// Convert task priority to event priority
  EventPriority _convertTaskPriority(final TaskPriority taskPriority) {
    switch (taskPriority) {
      case TaskPriority.low:
        return EventPriority.low;
      case TaskPriority.medium:
        return EventPriority.medium;
      case TaskPriority.high:
        return EventPriority.high;
      case TaskPriority.urgent:
        return EventPriority.urgent;
    }
  }

  /// Convert habit recurrence to event priority
  EventPriority _convertHabitPriority(final HabitRecurrence recurrence) {
    switch (recurrence) {
      case HabitRecurrence.daily:
        return EventPriority.high;
      case HabitRecurrence.weekly:
        return EventPriority.medium;
      case HabitRecurrence.weekdays:
        return EventPriority.medium;
      case HabitRecurrence.weekends:
        return EventPriority.low;
      case HabitRecurrence.custom:
        return EventPriority.medium;
    }
  }

  /// Clear all events (for testing)
  void clearAllEvents() {
    _events.clear();
  }
}
