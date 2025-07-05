import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Calendar event category enumeration
enum EventCategory {
  work,
  personal,
  health,
  education,
  social,
  travel,
  finance,
  habit,
  task,
  other,
}

/// Calendar event priority enumeration
enum EventPriority { low, medium, high, urgent }

/// Calendar event recurrence type
enum RecurrenceType { none, daily, weekly, monthly, yearly, custom }

/// Calendar event model for scheduling and time management
@immutable
class CalendarEvent {
  /// Primary constructor
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.category = EventCategory.other,
    this.priority = EventPriority.medium,
    this.color,
    this.isAllDay = false,
    this.location,
    this.notes,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceRule,
    this.reminderMinutes,
    this.taskId,
    this.habitId,
    this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
  });

  /// Create a new event with generated ID
  factory CalendarEvent.create({
    required final String title,
    required final DateTime startTime,
    required final DateTime endTime,
    final String? description,
    final EventCategory category = EventCategory.other,
    final EventPriority priority = EventPriority.medium,
    final Color? color,
    final bool isAllDay = false,
    final String? location,
    final String? notes,
    final RecurrenceType recurrenceType = RecurrenceType.none,
    final String? recurrenceRule,
    final List<int>? reminderMinutes,
    final String? taskId,
    final String? habitId,
  }) {
    final now = DateTime.now();
    return CalendarEvent(
      id: _generateId(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      category: category,
      priority: priority,
      color: color ?? getDefaultColorForCategory(category),
      isAllDay: isAllDay,
      location: location,
      notes: notes,
      recurrenceType: recurrenceType,
      recurrenceRule: recurrenceRule,
      reminderMinutes: reminderMinutes,
      taskId: taskId,
      habitId: habitId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Map from database
  factory CalendarEvent.fromMap(final Map<String, dynamic> map) =>
      CalendarEvent(
        id: map['id'] as String,
        title: map['title'] as String,
        startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
        endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
        description: map['description'] as String?,
        category: EventCategory.values.firstWhere(
          (final e) => e.name == map['category'],
          orElse: () => EventCategory.other,
        ),
        priority: EventPriority.values.firstWhere(
          (final e) => e.name == map['priority'],
          orElse: () => EventPriority.medium,
        ),
        color: map['color'] != null ? Color(map['color'] as int) : null,
        isAllDay: (map['isAllDay'] as int?) == 1,
        location: map['location'] as String?,
        notes: map['notes'] as String?,
        recurrenceType: RecurrenceType.values.firstWhere(
          (final e) => e.name == map['recurrenceType'],
          orElse: () => RecurrenceType.none,
        ),
        recurrenceRule: map['recurrenceRule'] as String?,
        reminderMinutes: map['reminderMinutes'] != null
            ? (map['reminderMinutes'] as String)
                  .split(',')
                  .where((final reminder) => reminder.isNotEmpty)
                  .map(int.parse)
                  .toList()
            : null,
        taskId: map['taskId'] as String?,
        habitId: map['habitId'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
            : null,
        isCompleted: (map['isCompleted'] as int?) == 1,
      );

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final EventCategory category;
  final EventPriority priority;
  final Color? color;
  final bool isAllDay;
  final String? location;
  final String? notes;
  final RecurrenceType recurrenceType;
  final String? recurrenceRule;
  final List<int>? reminderMinutes;
  final String? taskId;
  final String? habitId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;

  /// Copy with new values
  CalendarEvent copyWith({
    final String? id,
    final String? title,
    final DateTime? startTime,
    final DateTime? endTime,
    final String? description,
    final EventCategory? category,
    final EventPriority? priority,
    final Color? color,
    final bool? isAllDay,
    final String? location,
    final String? notes,
    final RecurrenceType? recurrenceType,
    final String? recurrenceRule,
    final List<int>? reminderMinutes,
    final String? taskId,
    final String? habitId,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool? isCompleted,
  }) => CalendarEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    description: description ?? this.description,
    category: category ?? this.category,
    priority: priority ?? this.priority,
    color: color ?? this.color,
    isAllDay: isAllDay ?? this.isAllDay,
    location: location ?? this.location,
    notes: notes ?? this.notes,
    recurrenceType: recurrenceType ?? this.recurrenceType,
    recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    taskId: taskId ?? this.taskId,
    habitId: habitId ?? this.habitId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  /// Update the event with new values
  CalendarEvent update({
    final String? title,
    final DateTime? startTime,
    final DateTime? endTime,
    final String? description,
    final EventCategory? category,
    final EventPriority? priority,
    final Color? color,
    final bool? isAllDay,
    final String? location,
    final String? notes,
    final RecurrenceType? recurrenceType,
    final String? recurrenceRule,
    final List<int>? reminderMinutes,
    final String? taskId,
    final String? habitId,
    final bool? isCompleted,
  }) => copyWith(
    title: title,
    startTime: startTime,
    endTime: endTime,
    description: description,
    category: category,
    priority: priority,
    color: color,
    isAllDay: isAllDay,
    location: location,
    notes: notes,
    recurrenceType: recurrenceType,
    recurrenceRule: recurrenceRule,
    reminderMinutes: reminderMinutes,
    taskId: taskId,
    habitId: habitId,
    updatedAt: DateTime.now(),
    isCompleted: isCompleted,
  );

  /// Mark event as completed
  CalendarEvent markCompleted() =>
      copyWith(isCompleted: true, updatedAt: DateTime.now());

  /// Get duration of the event
  Duration get duration => endTime.difference(startTime);

  /// Check if event is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(startTime.year, startTime.month, startTime.day);
    return today.isAtSameMomentAs(eventDay);
  }

  /// Check if event is in the past
  bool get isPast => endTime.isBefore(DateTime.now());

  /// Check if event is currently happening
  bool get isHappening {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  /// Check if event conflicts with another event
  bool conflictsWith(final CalendarEvent other) => startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);

  /// Convert to Syncfusion Appointment
  Appointment toAppointment() => Appointment(
    id: id,
    subject: title,
    startTime: startTime,
    endTime: endTime,
    color: color ?? getDefaultColorForCategory(category),
    isAllDay: isAllDay,
    notes: notes ?? description,
    location: location,
    recurrenceRule: recurrenceRule,
  );

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'startTime': startTime.millisecondsSinceEpoch,
    'endTime': endTime.millisecondsSinceEpoch,
    'description': description,
    'category': category.name,
    'priority': priority.name,
    'color': color?.value,
    'isAllDay': isAllDay ? 1 : 0,
    'location': location,
    'notes': notes,
    'recurrenceType': recurrenceType.name,
    'recurrenceRule': recurrenceRule,
    'reminderMinutes': reminderMinutes?.join(','),
    'taskId': taskId,
    'habitId': habitId,
    'createdAt': createdAt?.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
    'isCompleted': isCompleted ? 1 : 0,
  };

  /// Generate unique ID
  static String _generateId() =>
      'event_${DateTime.now().millisecondsSinceEpoch}';

  /// Get default color for category
  static Color getDefaultColorForCategory(final EventCategory category) {
    switch (category) {
      case EventCategory.work:
        return const Color(0xFF2196F3); // Blue
      case EventCategory.personal:
        return const Color(0xFF4CAF50); // Green
      case EventCategory.health:
        return const Color(0xFFE91E63); // Pink
      case EventCategory.education:
        return const Color(0xFF9C27B0); // Purple
      case EventCategory.social:
        return const Color(0xFFFF9800); // Orange
      case EventCategory.travel:
        return const Color(0xFF00BCD4); // Cyan
      case EventCategory.finance:
        return const Color(0xFF8BC34A); // Light Green
      case EventCategory.habit:
        return const Color(0xFF673AB7); // Deep Purple
      case EventCategory.task:
        return const Color(0xFFFF5722); // Deep Orange
      case EventCategory.other:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  /// Get icon for category
  static IconData getIconForCategory(final EventCategory category) {
    switch (category) {
      case EventCategory.work:
        return Icons.work;
      case EventCategory.personal:
        return Icons.person;
      case EventCategory.health:
        return Icons.favorite;
      case EventCategory.education:
        return Icons.school;
      case EventCategory.social:
        return Icons.group;
      case EventCategory.travel:
        return Icons.flight;
      case EventCategory.finance:
        return Icons.attach_money;
      case EventCategory.habit:
        return Icons.loop;
      case EventCategory.task:
        return Icons.task;
      case EventCategory.other:
        return Icons.event;
    }
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CalendarEvent(id: $id, title: $title, '
      'startTime: $startTime, endTime: $endTime, category: $category)';
}
