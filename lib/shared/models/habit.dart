import 'package:flutter/material.dart';

/// Habit recurrence enumeration
enum HabitRecurrence {
  daily,
  weekly,
  weekdays, // Monday-Friday
  weekends, // Saturday-Sunday
  custom,   // User-defined pattern
}

/// Habit model representing a user's habit with calendar integration
@immutable
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.recurrence,
    required this.createdAt,
    this.endDate,
    this.customSchedule = const [],
    this.isActive = true,
    this.color,
    this.icon,
    this.preferredTime,
    this.targetCount = 1,
    this.category,
    this.updatedAt,
  });

  /// Create a new habit with generated ID
  factory Habit.create({
    required final String title,
    required final String description,
    required final HabitRecurrence recurrence,
    final DateTime? endDate,
    final List<DateTime> customSchedule = const [],
    final String? color,
    final String? icon,
    final TimeOfDay? preferredTime,
    final int targetCount = 1,
    final String? category,
  }) {
    final now = DateTime.now();
    return Habit(
      id: _generateId(),
      title: title,
      description: description,
      recurrence: recurrence,
      createdAt: now,
      endDate: endDate,
      customSchedule: customSchedule,
      color: color,
      icon: icon,
      preferredTime: preferredTime,
      targetCount: targetCount,
      category: category,
      updatedAt: now,
    );
  }

  /// Create from Map from database
  factory Habit.fromMap(final Map<String, dynamic> map) => Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      recurrence: HabitRecurrence.values.firstWhere(
        (final e) => e.name == map['recurrence'],
        orElse: () => HabitRecurrence.daily,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int)
          : null,
      customSchedule: map['customSchedule'] != null
          ? (map['customSchedule'] as String)
              .split(',')
              .where((final dateStr) => dateStr.isNotEmpty)
              .map((final dateStr) => DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr)))
              .toList()
          : const [],
      isActive: (map['isActive'] as int) == 1,
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      preferredTime: map['preferredTime'] != null
          ? _parseTimeOfDay(map['preferredTime'] as String)
          : null,
      targetCount: map['targetCount'] as int? ?? 1,
      category: map['category'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  final String id;
  final String title;
  /// Alias for title to support legacy code
  String get name => title;
  final String description;
  final HabitRecurrence recurrence;
  final DateTime createdAt;
  final DateTime? endDate;
  final List<DateTime> customSchedule; // For custom patterns
  final bool isActive;
  final String? color;
  final String? icon;
  final TimeOfDay? preferredTime;
  final int targetCount;
  final String? category;
  final DateTime? updatedAt;

  /// Copy with new values
  Habit copyWith({
    final String? id,
    final String? title,
    final String? description,
    final HabitRecurrence? recurrence,
    final DateTime? createdAt,
    final DateTime? endDate,
    final List<DateTime>? customSchedule,
    final bool? isActive,
    final String? color,
    final String? icon,
    final TimeOfDay? preferredTime,
    final int? targetCount,
    final String? category,
    final DateTime? updatedAt,
  }) => Habit(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    recurrence: recurrence ?? this.recurrence,
    createdAt: createdAt ?? this.createdAt,
    endDate: endDate ?? this.endDate,
    customSchedule: customSchedule ?? this.customSchedule,
    isActive: isActive ?? this.isActive,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    preferredTime: preferredTime ?? this.preferredTime,
    targetCount: targetCount ?? this.targetCount,
    category: category ?? this.category,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  /// Update the habit with new values
  Habit update({
    final String? title,
    final String? description,
    final HabitRecurrence? recurrence,
    final DateTime? endDate,
    final List<DateTime>? customSchedule,
    final bool? isActive,
    final String? color,
    final String? icon,
    final TimeOfDay? preferredTime,
    final int? targetCount,
    final String? category,
  }) => copyWith(
    title: title,
    description: description,
    recurrence: recurrence,
    endDate: endDate,
    customSchedule: customSchedule,
    isActive: isActive,
    color: color,
    icon: icon,
    preferredTime: preferredTime,
    targetCount: targetCount,
    category: category,
    updatedAt: DateTime.now(),
  );

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'recurrence': recurrence.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'endDate': endDate?.millisecondsSinceEpoch,
    'customSchedule': customSchedule.map((final date) => date.millisecondsSinceEpoch.toString()).join(','),
    'isActive': isActive ? 1 : 0,
    'color': color,
    'icon': icon,
    'preferredTime': preferredTime != null
        ? _timeOfDayToString(preferredTime!)
        : null,
    'targetCount': targetCount,
    'category': category,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
  };

  /// Generate unique ID
  static String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Habit(id: $id, title: $title, recurrence: $recurrence, targetCount: $targetCount)';

  /// Check if the habit is scheduled for a given date
  bool isScheduledFor(final DateTime date) {
    // If there's an end date and we're past it, not scheduled
    if (endDate != null && date.isAfter(endDate!)) {
      return false;
    }
    
    // If habit is not active, not scheduled
    if (!isActive) {
      return false;
    }
    
    // If date is before creation date, not scheduled
    if (date.isBefore(DateTime(createdAt.year, createdAt.month, createdAt.day))) {
      return false;
    }
    
    switch (recurrence) {
      case HabitRecurrence.daily:
        return true;
      case HabitRecurrence.weekly:
        // Weekly on the same day of week as creation
        return date.weekday == createdAt.weekday;
      case HabitRecurrence.weekdays:
        // Monday (1) to Friday (5)
        return date.weekday >= 1 && date.weekday <= 5;
      case HabitRecurrence.weekends:
        // Saturday (6) and Sunday (7)
        return date.weekday == 6 || date.weekday == 7;
      case HabitRecurrence.custom:
        // Check if date is in custom schedule
        return customSchedule.any((final scheduledDate) => 
          scheduledDate.year == date.year &&
          scheduledDate.month == date.month &&
          scheduledDate.day == date.day
        );
    }
  }

  static TimeOfDay _parseTimeOfDay(final String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _timeOfDayToString(final TimeOfDay t) => '${t.hour}:${t.minute}';
}
