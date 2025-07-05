import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../models/habit.dart';
import '../models/task.dart';
import 'database_service.dart';

/// Service for managing calendar events
class CalendarService {
  static CalendarService? _instance;
  final DatabaseService _database = DatabaseService.instance;
  final List<CalendarEvent> _events = [];

  /// Get singleton instance
  static CalendarService get instance {
    _instance ??= CalendarService._();
    return _instance!;
  }

  CalendarService._();

  /// Get all events
  List<CalendarEvent> get events => List.unmodifiable(_events);

  /// Initialize service and load events
  Future<void> initialize() async {
    await _loadEvents();
  }

  /// Load events from database
  Future<void> _loadEvents() async {
    try {
      final events = await _database.getCalendarEvents();
      _events.clear();
      _events.addAll(events);
    } on Exception {
      // Handle error - for now just keep empty list
      _events.clear();
    }
  }

  /// Create a new event
  Future<CalendarEvent> createEvent({
    required final String title,
    required final DateTime startTime,
    required final DateTime endTime,
    final String? description,
    final EventCategory category = EventCategory.other,
    final EventPriority priority = EventPriority.medium,
    final String? location,
    final String? notes,
    final bool isAllDay = false,
    final RecurrenceType recurrenceType = RecurrenceType.none,
    final String? recurrenceRule,
    final List<int>? reminderMinutes,
    final String? taskId,
    final String? habitId,
  }) async {
    final event = CalendarEvent.create(
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      category: category,
      priority: priority,
      location: location,
      notes: notes,
      isAllDay: isAllDay,
      recurrenceType: recurrenceType,
      recurrenceRule: recurrenceRule,
      reminderMinutes: reminderMinutes,
      taskId: taskId,
      habitId: habitId,
    );

    _events.add(event);
    await _database.insertCalendarEvent(event);
    return event;
  }

  /// Create event from task
  Future<CalendarEvent> createEventFromTask({
    required final Task task,
    final DateTime? startTime,
    final Duration? duration,
  }) async {
    final eventStart = startTime ?? task.dueDate ?? DateTime.now();
    final eventDuration = duration ?? 
        Duration(minutes: task.estimatedMinutes ?? 60);
    final eventEnd = eventStart.add(eventDuration);

    return createEvent(
      title: task.title,
      startTime: eventStart,
      endTime: eventEnd,
      description: task.description,
      category: EventCategory.task,
      priority: _convertTaskPriority(task.priority),
      notes: 'Created from task: ${task.title}',
      taskId: task.id,
    );
  }

  /// Create event from habit
  Future<CalendarEvent> createEventFromHabit({
    required final Habit habit,
    required final DateTime date,
    final TimeOfDay? preferredTime,
    final Duration? duration,
  }) async {
    final time = preferredTime ?? const TimeOfDay(hour: 9, minute: 0);
    final eventStart = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final eventDuration = duration ?? const Duration(minutes: 30);
    final eventEnd = eventStart.add(eventDuration);

    return createEvent(
      title: habit.name,
      startTime: eventStart,
      endTime: eventEnd,
      description: habit.description,
      category: EventCategory.habit,
      priority: _convertHabitPriority(habit.recurrence),
      notes: 'Habit: ${habit.name} (${habit.category})',
      habitId: habit.id,
    );
  }

  /// Update an existing event
  Future<CalendarEvent> updateEvent(final CalendarEvent event) async {
    final index = _events.indexWhere((final e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _database.updateCalendarEvent(event);
      return event;
    }
    throw Exception('Event not found');
  }

  /// Delete an event
  Future<void> deleteEvent(final String eventId) async {
    _events.removeWhere((final event) => event.id == eventId);
    await _database.deleteCalendarEvent(eventId);
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDate(final DateTime date) {
    return _events.where((final event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(checkDate);
    }).toList();
  }

  /// Get events for a date range
  List<CalendarEvent> getEventsForDateRange({
    required final DateTime startDate,
    required final DateTime endDate,
  }) {
    return _events.where((final event) {
      return event.startTime.isAfter(startDate) &&
          event.startTime.isBefore(endDate);
    }).toList();
  }

  /// Get events by category
  List<CalendarEvent> getEventsByCategory(final EventCategory category) {
    return _events.where((final event) => event.category == category).toList();
  }

  /// Get upcoming events (next 7 days)
  List<CalendarEvent> getUpcomingEvents() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return _events.where((final event) {
      return event.startTime.isAfter(now) && 
          event.startTime.isBefore(weekFromNow);
    }).toList();
  }

  /// Get conflicting events for a time slot
  List<CalendarEvent> getConflictingEvents({
    required final DateTime startTime,
    required final DateTime endTime,
    final String? excludeEventId,
  }) {
    return _events.where((final event) {
      if (excludeEventId != null && event.id == excludeEventId) {
        return false;
      }
      return startTime.isBefore(event.endTime) && endTime.isAfter(event.startTime);
    }).toList();
  }

  /// Move event to new time slot
  Future<CalendarEvent> moveEvent({
    required final String eventId,
    required final DateTime newStartTime,
    final DateTime? newEndTime,
  }) async {
    final event = _events.firstWhere((final e) => e.id == eventId);
    final duration = newEndTime != null 
        ? newEndTime.difference(newStartTime)
        : event.duration;
    
    final updatedEvent = event.update(
      startTime: newStartTime,
      endTime: newStartTime.add(duration),
    );
    
    return updateEvent(updatedEvent);
  }

  /// Mark event as completed
  Future<CalendarEvent> completeEvent(final String eventId) async {
    final event = _events.firstWhere((final e) => e.id == eventId);
    final completedEvent = event.markCompleted();
    return updateEvent(completedEvent);
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
