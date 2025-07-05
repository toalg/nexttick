import 'package:flutter/foundation.dart';

/// Habit completion model for tracking habit completions with calendar integration
@immutable
class HabitCompletion {
  /// Primary constructor
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.completionDate,
    this.taskId,
    this.notes,
    this.completionCount = 1,
  });

  /// Create a new completion with generated ID
  factory HabitCompletion.create({
    required final String habitId,
    required final DateTime completedAt,
    final String? taskId,
    final String? notes,
    final int completionCount = 1,
  }) {
    final completionDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    
    return HabitCompletion(
      id: _generateId(),
      habitId: habitId,
      completedAt: completedAt,
      completionDate: completionDate,
      taskId: taskId,
      notes: notes,
      completionCount: completionCount,
    );
  }

  /// Create from Map from database
  factory HabitCompletion.fromMap(final Map<String, dynamic> map) =>
      HabitCompletion(
        id: map['id'] as String,
        habitId: map['habitId'] as String,
        completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
        completionDate: DateTime.fromMillisecondsSinceEpoch(map['completionDate'] as int),
        taskId: map['taskId'] as String?,
        notes: map['notes'] as String?,
        completionCount: map['completionCount'] as int? ?? 1,
      );

  final String id;
  final String habitId;
  final String? taskId;
  final DateTime completedAt;
  final DateTime completionDate; // For calendar queries
  /// Alias for completionDate to support legacy code
  DateTime get date => completionDate;
  /// Completion count for the day (defaults to 1)
  final int completionCount;
  final String? notes;

  /// Copy with new values
  HabitCompletion copyWith({
    final String? id,
    final String? habitId,
    final String? taskId,
    final DateTime? completedAt,
    final DateTime? completionDate,
    final String? notes,
    final int? completionCount,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    taskId: taskId ?? this.taskId,
    completedAt: completedAt ?? this.completedAt,
    completionDate: completionDate ?? this.completionDate,
    notes: notes ?? this.notes,
    completionCount: completionCount ?? this.completionCount,
  );

  /// Update the completion with new values
  HabitCompletion update({
    final String? notes,
    final int? completionCount,
  }) => copyWith(
    notes: notes,
    completionCount: completionCount,
  );

  /// Check if completion is for today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completionDate.isAtSameMomentAs(today);
  }

  /// Check if completion is for this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return completionDate.isAfter(weekStart) && completionDate.isBefore(weekEnd);
  }

  /// Get days since completion
  int get daysSinceCompletion {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(completionDate).inDays;
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'habitId': habitId,
    'taskId': taskId,
    'completedAt': completedAt.millisecondsSinceEpoch,
    'completionDate': completionDate.millisecondsSinceEpoch,
    'notes': notes,
    'completionCount': completionCount,
  };

  /// Generate unique ID
  static String _generateId() =>
      'completion_${DateTime.now().millisecondsSinceEpoch}';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HabitCompletion(id: $id, habitId: $habitId, '
      'completedAt: $completedAt, completionDate: $completionDate)';
}
