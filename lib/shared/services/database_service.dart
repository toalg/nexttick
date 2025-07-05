import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexttick/shared/models/habit.dart';
import 'package:nexttick/shared/models/task.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:nexttick/shared/models/habit_completion.dart';

/// Database service for managing local data with web compatibility
class DatabaseService {
  DatabaseService._();
  static DatabaseService? _instance;
  static SharedPreferences? _prefs;

  /// Get singleton instance
  factory DatabaseService() {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get singleton instance (backward compatibility)
  static DatabaseService get instance => DatabaseService();

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Initialize database
  Future<void> initialize() async {
    await _preferences; // Initialize storage
  }

  // Storage keys
  static const String _habitsKey = 'habits';
  static const String _tasksKey = 'tasks';
  static const String _completionsKey = 'habit_completions';
  static const String _calendarEventsKey = 'calendar_events';

  /// Helper method to get list from storage
  Future<List<Map<String, dynamic>>> _getList(String key) async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  /// Helper method to save list to storage
  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await _preferences;
    final jsonString = jsonEncode(list);
    await prefs.setString(key, jsonString);
  }

  /// Helper method to add item to list
  Future<void> _addToList(String key, Map<String, dynamic> item) async {
    final list = await _getList(key);
    list.add(item);
    await _saveList(key, list);
  }

  /// Helper method to update item in list
  Future<void> _updateInList(String key, String id, Map<String, dynamic> updatedItem) async {
    final list = await _getList(key);
    final index = list.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      list[index] = updatedItem;
      await _saveList(key, list);
    }
  }

  /// Helper method to remove item from list
  Future<void> _removeFromList(String key, String id) async {
    final list = await _getList(key);
    list.removeWhere((item) => item['id'] == id);
    await _saveList(key, list);
  }

  /// Habit operations
  Future<void> insertHabit(final Habit habit) async {
    await _addToList(_habitsKey, habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final list = await _getList(_habitsKey);
    return list.map((item) => Habit.fromMap(item)).toList();
  }

  Future<List<Habit>> getHabits() async {
    return getAllHabits();
  }

  Future<Habit?> getHabitById(final String id) async {
    final list = await _getList(_habitsKey);
    try {
      final habitMap = list.firstWhere((item) => item['id'] == id);
      return Habit.fromMap(habitMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateHabit(final Habit habit) async {
    await _updateInList(_habitsKey, habit.id, habit.toMap());
  }

  Future<void> deleteHabit(final String id) async {
    await _removeFromList(_habitsKey, id);
  }

  Future<List<Habit>> getHabitsByCategory(final String category) async {
    final list = await _getList(_habitsKey);
    final filtered = list.where((item) => item['category'] == category).toList();
    return filtered.map((item) => Habit.fromMap(item)).toList();
  }

  /// Task operations
  Future<void> insertTask(final Task task) async {
    await _addToList(_tasksKey, task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final list = await _getList(_tasksKey);
    return list.map((item) => Task.fromMap(item)).toList();
  }

  Future<List<Task>> getTasks(final DateTime day) async {
    final list = await _getList(_tasksKey);
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final filtered = list.where((item) {
      if (item['due_date'] == null) return false;
      final dueDate = DateTime.fromMillisecondsSinceEpoch(item['due_date'] as int);
      return dueDate.isAfter(startOfDay) && dueDate.isBefore(endOfDay);
    }).toList();
    
    return filtered.map((item) => Task.fromMap(item)).toList();
  }

  Future<List<Task>> getTasksByHabitId(final String habitId) async {
    final list = await _getList(_tasksKey);
    final filtered = list.where((item) => item['habit_id'] == habitId).toList();
    return filtered.map((item) => Task.fromMap(item)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final list = await _getList(_tasksKey);
    try {
      final taskMap = list.firstWhere((item) => item['id'] == id);
      return Task.fromMap(taskMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTask(final Task task) async {
    await _updateInList(_tasksKey, task.id, task.toMap());
  }

  Future<void> deleteTask(final String id) async {
    await _removeFromList(_tasksKey, id);
  }

  Future<List<Task>> getTasksDueToday() async {
    return getTasks(DateTime.now());
  }

  Future<List<Task>> getTasksDueThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final list = await _getList(_tasksKey);
    final filtered = list.where((item) {
      if (item['due_date'] == null) return false;
      final dueDate = DateTime.fromMillisecondsSinceEpoch(item['due_date'] as int);
      return dueDate.isAfter(weekStart) && dueDate.isBefore(weekEnd);
    }).toList();
    
    return filtered.map((item) => Task.fromMap(item)).toList();
  }

  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    final list = await _getList(_tasksKey);
    final filtered = list.where((item) {
      if (item['due_date'] == null) return false;
      final dueDate = DateTime.fromMillisecondsSinceEpoch(item['due_date'] as int);
      return dueDate.isBefore(now) && !((item['is_completed'] as bool?) ?? false);
    }).toList();
    
    return filtered.map((item) => Task.fromMap(item)).toList();
  }

  /// Completion operations
  Future<void> insertCompletion(final HabitCompletion completion) async {
    await _addToList(_completionsKey, completion.toMap());
  }

  Future<List<HabitCompletion>> getHabitCompletions(final DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final list = await _getList(_completionsKey);
    final filtered = list.where((item) {
      final completionDate = DateTime.fromMillisecondsSinceEpoch(item['completion_date'] as int);
      return completionDate.isAfter(startOfDay) && completionDate.isBefore(endOfDay);
    }).toList();
    
    return filtered.map((item) => HabitCompletion.fromMap(item)).toList();
  }

  Future<List<HabitCompletion>> getCompletionsByHabitId(
    final String habitId, {
    final DateTime? startDate,
    final DateTime? endDate,
  }) async {
    final list = await _getList(_completionsKey);
    
    var filtered = list.where((item) => item['habit_id'] == habitId);
    
    if (startDate != null) {
      filtered = filtered.where((item) {
        final completionDate = DateTime.fromMillisecondsSinceEpoch(item['completion_date'] as int);
        return completionDate.isAfter(startDate) || completionDate.isAtSameMomentAs(startDate);
      });
    }
    
    if (endDate != null) {
      filtered = filtered.where((item) {
        final completionDate = DateTime.fromMillisecondsSinceEpoch(item['completion_date'] as int);
        return completionDate.isBefore(endDate) || completionDate.isAtSameMomentAs(endDate);
      });
    }
    
    return filtered.map((item) => HabitCompletion.fromMap(item)).toList();
  }

  /// Calendar Event operations
  Future<void> insertCalendarEvent(final CalendarEvent event) async {
    await _addToList(_calendarEventsKey, event.toMap());
  }

  Future<List<CalendarEvent>> getCalendarEvents() async {
    final list = await _getList(_calendarEventsKey);
    return list.map((item) => CalendarEvent.fromMap(item)).toList();
  }

  Future<List<CalendarEvent>> getCalendarEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final list = await _getList(_calendarEventsKey);
    final filtered = list.where((item) {
      final eventStart = DateTime.fromMillisecondsSinceEpoch(item['start_time']);
      return eventStart.isAfter(startDate) && eventStart.isBefore(endDate);
    }).toList();
    
    return filtered.map((item) => CalendarEvent.fromMap(item)).toList();
  }

  Future<CalendarEvent?> getCalendarEventById(String id) async {
    final list = await _getList(_calendarEventsKey);
    try {
      final eventMap = list.firstWhere((item) => item['id'] == id);
      return CalendarEvent.fromMap(eventMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    await _updateInList(_calendarEventsKey, event.id, event.toMap());
  }

  Future<void> deleteCalendarEvent(String id) async {
    await _removeFromList(_calendarEventsKey, id);
  }

  Future<List<CalendarEvent>> getCalendarEventsByCategory(
    EventCategory category,
  ) async {
    final list = await _getList(_calendarEventsKey);
    final filtered = list.where((item) => item['category'] == category.name).toList();
    return filtered.map((item) => CalendarEvent.fromMap(item)).toList();
  }

  /// Progress operations
  Future<void> insertProgress(Map<String, dynamic> progress) async {
    // For now, just store as metadata
    final prefs = await _preferences;
    final progressKey = 'progress_${progress['habit_id']}_${progress['date']}';
    await prefs.setString(progressKey, jsonEncode(progress));
  }

  Future<Map<String, dynamic>?> getProgressByHabitIdAndDate(
    String habitId,
    String date,
  ) async {
    final prefs = await _preferences;
    final progressKey = 'progress_${habitId}_$date';
    final jsonString = prefs.getString(progressKey);
    if (jsonString == null) return null;
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  Future<List<Map<String, dynamic>>> getProgressByHabitId(
    String habitId, {
    int limit = 30,
  }) async {
    final prefs = await _preferences;
    final keys = prefs.getKeys().where((key) => key.startsWith('progress_$habitId'));
    final progressList = <Map<String, dynamic>>[];
    
    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        progressList.add(Map<String, dynamic>.from(jsonDecode(jsonString)));
      }
    }
    
    // Sort by date and limit
    progressList.sort((a, b) => b['date'].compareTo(a['date']));
    return progressList.take(limit).toList();
  }

  Future<void> updateProgress(Map<String, dynamic> progress) async {
    await insertProgress(progress); // Same as insert for SharedPreferences
  }

  /// Analytics queries
  Future<Map<String, dynamic>> getHabitStats(String habitId) async {
    final completions = await getCompletionsByHabitId(habitId);
    final totalCompletions = completions.length;
    
    // Calculate current streak
    var currentStreak = 0;
    final now = DateTime.now();
    for (var i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasCompletion = completions.any((completion) {
        final completionDate = DateTime(
          completion.date.year,
          completion.date.month,
          completion.date.day,
        );
        final checkDateOnly = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
        );
        return completionDate.isAtSameMomentAs(checkDateOnly);
      });
      
      if (hasCompletion) {
        currentStreak++;
      } else {
        break;
      }
    }
    
    return {
      'totalCompletions': totalCompletions,
      'currentStreak': currentStreak,
      'recentCompletions': completions.where((c) => 
        c.completedAt.isAfter(now.subtract(const Duration(days: 7)))
      ).length,
      'completionRate': totalCompletions > 0 ? 1.0 : 0.0,
    };
  }

  /// Database maintenance
  Future<void> clearOldData() async {
    // Clear data older than 1 year
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    
    // Clear old completions
    final completions = await _getList(_completionsKey);
    final recentCompletions = completions.where((item) {
      final completionDate = DateTime.fromMillisecondsSinceEpoch(item['completion_date'] as int);
      return completionDate.isAfter(oneYearAgo);
    }).toList();
    await _saveList(_completionsKey, recentCompletions);
  }

  /// Export data for backup
  Future<Map<String, dynamic>> exportData() async {
    return {
      'habits': await _getList(_habitsKey),
      'tasks': await _getList(_tasksKey),
      'completions': await _getList(_completionsKey),
      'calendar_events': await _getList(_calendarEventsKey),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    if (data['habits'] != null) {
      await _saveList(_habitsKey, List<Map<String, dynamic>>.from(data['habits']));
    }
    if (data['tasks'] != null) {
      await _saveList(_tasksKey, List<Map<String, dynamic>>.from(data['tasks']));
    }
    if (data['completions'] != null) {
      await _saveList(_completionsKey, List<Map<String, dynamic>>.from(data['completions']));
    }
    if (data['calendar_events'] != null) {
      await _saveList(_calendarEventsKey, List<Map<String, dynamic>>.from(data['calendar_events']));
    }
  }

  /// Close database
  Future<void> close() async {
    // Nothing to close for SharedPreferences
  }
}