import '../models/task.dart';
import '../models/habit.dart';
import 'database_service.dart';

/// Service for managing tasks with calendar integration
class TaskService {
  static TaskService? _instance;
  final DatabaseService _database = DatabaseService.instance;

  /// Get singleton instance
  static TaskService get instance {
    _instance ??= TaskService._();
    return _instance!;
  }

  TaskService._();

  /// Create a new task
  Future<Task> createTask({
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
  }) async {
    final task = Task.create(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      habitId: habitId,
      category: category,
      color: color,
      icon: icon,
      tags: tags,
      estimatedMinutes: estimatedMinutes,
    );

    await _database.insertTask(task);
    return task;
  }

  /// Create task from habit
  Future<Task> createTaskFromHabit({
    required final Habit habit,
    required final DateTime dueDate,
    final String? additionalDescription,
    final TaskPriority? priority,
  }) async {
    final description = additionalDescription != null
        ? '${habit.description}\n\n$additionalDescription'
        : habit.description;

    return createTask(
      title: habit.name,
      description: description,
      priority: priority ?? _getDefaultPriorityForHabit(habit),
      dueDate: dueDate,
      habitId: habit.id,
      category: habit.category,
      color: habit.color,
      icon: habit.icon,
      tags: habit.category != null ? [habit.category!] : [],
    );
  }

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    return _database.getAllTasks();
  }

  /// Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    final tasks = await _database.getAllTasks();
    return tasks.where((task) => task.isDueToday).toList();
  }

  /// Get tasks due this week
  Future<List<Task>> getTasksDueThisWeek() async {
    final tasks = await _database.getAllTasks();
    return tasks.where((task) => task.isDueThisWeek).toList();
  }

  /// Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    final tasks = await _database.getAllTasks();
    return tasks.where((task) => task.isOverdue).toList();
  }

  /// Get tasks for a specific date
  Future<List<Task>> getTasksForDate(final DateTime date) async {
    final tasks = await _database.getAllTasks();
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return dueDate.isAtSameMomentAs(checkDate);
    }).toList();
  }

  /// Get tasks by priority
  Future<List<Task>> getTasksByPriority(final TaskPriority priority) async {
    final tasks = await _database.getAllTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  /// Get tasks by status
  Future<List<Task>> getTasksByStatus(final TaskStatus status) async {
    final tasks = await _database.getAllTasks();
    return tasks.where((task) => task.status == status).toList();
  }

  /// Get tasks by habit
  Future<List<Task>> getTasksByHabit(final String habitId) async {
    return _database.getTasksByHabitId(habitId);
  }

  /// Update task
  Future<Task> updateTask(final Task task) async {
    await _database.updateTask(task);
    return task;
  }

  /// Complete task
  Future<Task> completeTask(final String taskId) async {
    final task = await _database.getTaskById(taskId);
    if (task == null) throw Exception('Task not found');

    final completedTask = task.markCompleted();
    await _database.updateTask(completedTask);
    return completedTask;
  }

  /// Mark task as in progress
  Future<Task> startTask(final String taskId) async {
    final task = await _database.getTaskById(taskId);
    if (task == null) throw Exception('Task not found');

    final inProgressTask = task.markInProgress();
    await _database.updateTask(inProgressTask);
    return inProgressTask;
  }

  /// Update task due date
  Future<Task> updateTaskDueDate(
    final String taskId,
    final DateTime? newDueDate,
  ) async {
    final task = await _database.getTaskById(taskId);
    if (task == null) throw Exception('Task not found');

    final updatedTask = task.update(dueDate: newDueDate);
    await _database.updateTask(updatedTask);
    return updatedTask;
  }

  /// Delete task
  Future<void> deleteTask(final String taskId) async {
    await _database.deleteTask(taskId);
  }

  /// Get upcoming tasks (next 7 days)
  Future<List<Task>> getUpcomingTasks() async {
    final tasks = await _database.getAllTasks();
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(weekFromNow);
    }).toList();
  }

  /// Reschedule overdue tasks
  Future<List<Task>> rescheduleOverdueTasks({
    final Duration? defaultExtension,
  }) async {
    final overdueTasks = await getOverdueTasks();
    final extension = defaultExtension ?? const Duration(days: 1);
    final rescheduledTasks = <Task>[];

    for (final task in overdueTasks) {
      if (task.dueDate != null) {
        final newDueDate = task.dueDate!.add(extension);
        final rescheduledTask = await updateTaskDueDate(task.id, newDueDate);
        rescheduledTasks.add(rescheduledTask);
      }
    }

    return rescheduledTasks;
  }

  /// Generate recurring tasks from habits
  Future<List<Task>> generateTasksFromHabits({
    final DateTime? startDate,
    final DateTime? endDate,
  }) async {
    final habits = await _database.getAllHabits();
    final start = startDate ?? DateTime.now();
    final end = endDate ?? start.add(const Duration(days: 30));
    final generatedTasks = <Task>[];

    for (final habit in habits) {
      if (!habit.isActive) continue;

      for (DateTime date = start;
          date.isBefore(end);
          date = date.add(const Duration(days: 1))) {
        if (habit.isScheduledFor(date)) {
          // Check if task already exists for this date
          final existingTasks = await getTasksForDate(date);
          final habitTaskExists = existingTasks.any(
            (task) => task.habitId == habit.id,
          );

          if (!habitTaskExists) {
            final task = await createTaskFromHabit(
              habit: habit,
              dueDate: date,
            );
            generatedTasks.add(task);
          }
        }
      }
    }

    return generatedTasks;
  }

  /// Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final tasks = await _database.getAllTasks();
    final now = DateTime.now();

    final completed = tasks.where(
      (task) => task.status == TaskStatus.completed,
    ).length;
    final pending = tasks.where(
      (task) => task.status == TaskStatus.pending,
    ).length;
    final inProgress = tasks.where(
      (task) => task.status == TaskStatus.inProgress,
    ).length;
    final overdue = tasks.where((task) => task.isOverdue).length;

    return {
      'totalTasks': tasks.length,
      'completed': completed,
      'pending': pending,
      'inProgress': inProgress,
      'overdue': overdue,
      'completionRate': tasks.isNotEmpty ? completed / tasks.length : 0.0,
    };
  }

  /// Helper method to get default priority for habit
  TaskPriority _getDefaultPriorityForHabit(final Habit habit) {
    switch (habit.recurrence) {
      case HabitRecurrence.daily:
        return TaskPriority.high;
      case HabitRecurrence.weekly:
        return TaskPriority.medium;
      case HabitRecurrence.weekdays:
        return TaskPriority.medium;
      case HabitRecurrence.weekends:
        return TaskPriority.low;
      case HabitRecurrence.custom:
        return TaskPriority.medium;
    }
  }
}
