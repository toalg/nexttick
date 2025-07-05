import 'package:flutter/foundation.dart';

/// Task priority enumeration
enum TaskPriority { low, medium, high, urgent }

/// Task status enumeration
enum TaskStatus { pending, inProgress, completed, cancelled }

/// Task model representing a user's task with calendar integration
@immutable
class Task {
  /// Primary constructor for creating a task
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.habitId,
    this.category,
    this.color,
    this.icon,
    this.tags = const [],
    this.estimatedMinutes,
    this.completedAt,
  });

  /// Create a new task with generated ID
  factory Task.create({
    required final String title,
    required final String description,
    final TaskPriority priority = TaskPriority.medium,
    final DateTime? dueDate,
    final String? habitId,
    final String? category,
    final String? color,
    final String? icon,
    final List<String> tags = const [],
    final int? estimatedMinutes,
  }) {
    final now = DateTime.now();
    return Task(
      id: _generateId(),
      title: title,
      description: description,
      priority: priority,
      status: TaskStatus.pending,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      habitId: habitId,
      category: category,
      color: color,
      icon: icon,
      tags: tags,
      estimatedMinutes: estimatedMinutes,
    );
  }

  /// Create from Map from database
  factory Task.fromMap(final Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    priority: TaskPriority.values.firstWhere(
      (final e) => e.name == map['priority'],
      orElse: () => TaskPriority.medium,
    ),
    status: TaskStatus.values.firstWhere(
      (final e) => e.name == map['status'],
      orElse: () => TaskStatus.pending,
    ),
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    dueDate: map['dueDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
        : null,
    habitId: map['habitId'] as String?,
    category: map['category'] as String?,
    color: map['color'] as String?,
    icon: map['icon'] as String?,
    tags: map['tags'] != null
        ? (map['tags'] as String)
              .split(',')
              .where((final tag) => tag.isNotEmpty)
              .toList()
        : [],
    estimatedMinutes: map['estimatedMinutes'] as int?,
    completedAt: map['completedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
        : null,
  );

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final String? habitId;
  final String? category;
  final String? color;
  final String? icon;
  final List<String> tags;
  final int? estimatedMinutes;
  final DateTime? completedAt;

  /// Copy with new values
  Task copyWith({
    final String? id,
    final String? title,
    final String? description,
    final TaskPriority? priority,
    final TaskStatus? status,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? dueDate,
    final String? habitId,
    final String? category,
    final String? color,
    final String? icon,
    final List<String>? tags,
    final int? estimatedMinutes,
    final DateTime? completedAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dueDate: dueDate ?? this.dueDate,
    habitId: habitId ?? this.habitId,
    category: category ?? this.category,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    tags: tags ?? this.tags,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    completedAt: completedAt ?? this.completedAt,
  );

  /// Update the task with new values
  Task update({
    final String? title,
    final String? description,
    final TaskPriority? priority,
    final TaskStatus? status,
    final DateTime? dueDate,
    final String? habitId,
    final String? category,
    final String? color,
    final String? icon,
    final List<String>? tags,
    final int? estimatedMinutes,
  }) => copyWith(
    title: title,
    description: description,
    priority: priority,
    status: status,
    updatedAt: DateTime.now(),
    dueDate: dueDate,
    habitId: habitId,
    category: category,
    color: color,
    icon: icon,
    tags: tags,
    estimatedMinutes: estimatedMinutes,
  );

  /// Mark task as completed
  Task markCompleted() {
    final now = DateTime.now();
    return copyWith(
      status: TaskStatus.completed,
      completedAt: now,
      updatedAt: now,
    );
  }

  /// Mark task as in progress
  Task markInProgress() =>
      copyWith(status: TaskStatus.inProgress, updatedAt: DateTime.now());

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today.isAtSameMomentAs(due);
  }

  /// Check if task is due this week
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return dueDate!.isAfter(weekStart) && dueDate!.isBefore(weekEnd);
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.name,
    'status': status.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'habitId': habitId,
    'category': category,
    'color': color,
    'icon': icon,
    'tags': tags.join(','),
    'estimatedMinutes': estimatedMinutes,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  /// Generate unique ID
  static String _generateId() =>
      'task_${DateTime.now().millisecondsSinceEpoch}';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Task(id: $id, title: $title, '
      'priority: $priority, status: $status, dueDate: $dueDate)';
}
