import 'dart:async';

import 'package:nexttick/shared/models/habit.dart';
import 'package:nexttick/shared/models/habit_completion.dart';
import 'package:nexttick/shared/models/task.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Database service for managing local SQLite database
class DatabaseService {

  DatabaseService._();
  static DatabaseService? _instance;
  static Database? _database;

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'nexttick.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(final Database db, final int version) async {
    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        frequency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        color TEXT,
        icon TEXT,
        category TEXT,
        reminder_time TEXT,
        streak_count INTEGER DEFAULT 0,
        total_completions INTEGER DEFAULT 0
      )
    ''');

    // Habit completions table
    await db.execute('''
      CREATE TABLE habit_completions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        notes TEXT,
        mood_rating INTEGER,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        completed_at TEXT,
        tags TEXT,
        subtasks TEXT,
        habit_id TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE SET NULL
      )
    ''');

    // Calendar events table
    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        location TEXT,
        category TEXT,
        priority TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        total_habits INTEGER DEFAULT 0,
        completed_habits INTEGER DEFAULT 0,
        total_tasks INTEGER DEFAULT 0,
        completed_tasks INTEGER DEFAULT 0,
        xp_earned INTEGER DEFAULT 0,
        streak_maintained INTEGER DEFAULT 0,
        mood_rating INTEGER,
        notes TEXT
      )
    ''');
  }

  /// Upgrade database schema
  Future<void> _onUpgrade(final Database db, final int oldVersion, final int newVersion) async {
    // Handle future schema upgrades here
  }

  // ===== HABITS =====

  /// Save a habit to the database
  Future<void> saveHabit(final Habit habit) async {
    final db = await database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all habits
  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (final i) => Habit.fromMap(maps[i]));
  }

  /// Get active habits
  Future<List<Habit>> getActiveHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (final i) => Habit.fromMap(maps[i]));
  }

  /// Get habit by ID
  Future<Habit?> getHabitById(final String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  /// Update a habit
  Future<void> updateHabit(final String id, final Habit updatedHabit) async {
    final db = await database;
    await db.update(
      'habits',
      updatedHabit.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a habit
  Future<void> deleteHabit(final String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  /// Get habits by category
  Future<List<Habit>> getHabitsByCategory(final String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'category = ? AND is_active = ?',
      whereArgs: [category, 1],
    );
    return List.generate(maps.length, (final i) => Habit.fromMap(maps[i]));
  }

  /// Get habits for a specific date range
  Future<List<Habit>> getHabitsForDateRange(
    final DateTime startDate,
    final DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (final i) => Habit.fromMap(maps[i]));
  }

  // ===== HABIT COMPLETIONS =====

  /// Save a habit completion
  Future<void> saveHabitCompletion(final HabitCompletion completion) async {
    final db = await database;
    await db.insert(
      'habit_completions',
      completion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get completions for a habit
  Future<List<HabitCompletion>> getCompletionsForHabit(
    final String habitId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
    );
    return List.generate(maps.length, (final i) => HabitCompletion.fromMap(maps[i]));
  }

  /// Get completions for a date range
  Future<List<HabitCompletion>> getCompletionsForDateRange(
    final DateTime startDate,
    final DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'completed_at BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'completed_at DESC',
    );
    return List.generate(maps.length, (final i) => HabitCompletion.fromMap(maps[i]));
  }

  /// Get recent completions for a habit
  Future<List<HabitCompletion>> getRecentCompletions(
    final String habitId,
    final int limit,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (final i) => HabitCompletion.fromMap(maps[i]));
  }

  /// Delete a completion
  Future<void> deleteCompletion(final String id) async {
    final db = await database;
    await db.delete('habit_completions', where: 'id = ?', whereArgs: [id]);
  }

  // ===== TASKS =====

  /// Save a task
  Future<void> saveTask(final Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (final i) => Task.fromMap(maps[i]));
  }

  /// Get tasks by status
  Future<List<Task>> getTasksByStatus(final String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (final i) => Task.fromMap(maps[i]));
  }

  /// Get tasks for a date range
  Future<List<Task>> getTasksForDateRange(
    final DateTime startDate,
    final DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'due_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (final i) => Task.fromMap(maps[i]));
  }

  /// Update task status
  Future<void> updateTaskStatus(final String id, final String status) async {
    final db = await database;
    await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a task
  Future<void> deleteTask(final String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ===== USER PROGRESS =====

  /// Save user progress
  Future<void> saveProgress(final Map<String, dynamic> progress) async {
    final db = await database;
    await db.insert(
      'user_progress',
      progress,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get progress for a date
  Future<Map<String, dynamic>?> getProgressForDate(final String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// Get progress for date range
  Future<List<Map<String, dynamic>>> getProgressForDateRange(
    final DateTime startDate,
    final DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date ASC',
    );
    return maps;
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ===== BACKWARD COMPATIBILITY METHODS =====

  /// Initialize database (backward compatibility)
  Future<void> initialize() async {
    await database; // Just ensure database is initialized
  }

  /// Insert habit (backward compatibility)
  Future<void> insertHabit(final Habit habit) async {
    await saveHabit(habit);
  }

  /// Insert task (backward compatibility)
  Future<void> insertTask(final Task task) async {
    await saveTask(task);
  }

  /// Update task (backward compatibility)
  Future<void> updateTask(final Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Get task by ID (backward compatibility)
  Future<Task?> getTaskById(final String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  /// Get tasks by habit ID (backward compatibility)
  Future<List<Task>> getTasksByHabitId(final String habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return List.generate(maps.length, (final i) => Task.fromMap(maps[i]));
  }

  /// Get completions by habit ID (backward compatibility)
  Future<List<HabitCompletion>> getCompletionsByHabitId(
    final String habitId, {
    final DateTime? startDate,
    final DateTime? endDate,
  }) async {
    final db = await database;
    String whereClause = 'habit_id = ?';
    final List<Object> whereArgs = [habitId];

    if (startDate != null) {
      whereClause += ' AND completed_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND completed_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'completed_at DESC',
    );
    return List.generate(maps.length, (final i) => HabitCompletion.fromMap(maps[i]));
  }

  /// Get habit completions for a specific day (backward compatibility)
  Future<List<HabitCompletion>> getHabitCompletions(final DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getCompletionsForDateRange(startOfDay, endOfDay);
  }

  // ===== CALENDAR EVENTS (backward compatibility) =====

  /// Get all calendar events (backward compatibility)
  Future<List<Map<String, dynamic>>> getCalendarEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('calendar_events');
    return maps;
  }

  /// Insert calendar event (backward compatibility)
  Future<void> insertCalendarEvent(final Map<String, dynamic> event) async {
    final db = await database;
    await db.insert(
      'calendar_events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update calendar event (backward compatibility)
  Future<void> updateCalendarEvent(final Map<String, dynamic> event) async {
    final db = await database;
    await db.update(
      'calendar_events',
      event,
      where: 'id = ?',
      whereArgs: [event['id']],
    );
  }

  /// Delete calendar event (backward compatibility)
  Future<void> deleteCalendarEvent(final String id) async {
    final db = await database;
    await db.delete('calendar_events', where: 'id = ?', whereArgs: [id]);
  }
}
