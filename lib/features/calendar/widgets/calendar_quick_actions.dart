import 'package:flutter/material.dart';
import 'package:nexttick/core/theme/app_theme.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:nexttick/shared/models/habit.dart';
import 'package:nexttick/shared/services/calendar_service.dart';
import 'package:nexttick/shared/services/database_service.dart';
import 'package:nexttick/shared/services/task_service.dart';

/// Quick action buttons for calendar operations
class CalendarQuickActions extends StatelessWidget {
  const CalendarQuickActions({
    this.selectedDate,
    this.onActionCompleted,
    super.key,
  });

  final DateTime? selectedDate;
  final VoidCallback? onActionCompleted;

  @override
  Widget build(final BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);
    final date = selectedDate ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Icon(Icons.flash_on, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick action buttons
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildQuickActionTile(
                context,
                colorScheme,
                'Create Event',
                'Schedule a new event',
                Icons.event_note,
                colorScheme.primary,
                () => _createEvent(context, date),
              ),
              _buildQuickActionTile(
                context,
                colorScheme,
                'Add Task',
                'Create task with due date',
                Icons.task_alt,
                Colors.orange,
                () => _createTask(context, date),
              ),
              _buildQuickActionTile(
                context,
                colorScheme,
                'Schedule Habit',
                'Plan habit for this day',
                Icons.loop,
                Colors.green,
                () => _scheduleHabit(context, date),
              ),
              _buildQuickActionTile(
                context,
                colorScheme,
                'Quick Note',
                'Add a quick reminder',
                Icons.note_add,
                Colors.purple,
                () => _createQuickNote(context, date),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Additional actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _scheduleFromTemplate(context, date),
                  icon: const Icon(Icons.content_copy),
                  label: const Text('From Template'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _bulkSchedule(context, date),
                  icon: const Icon(Icons.calendar_view_week),
                  label: const Text('Bulk Schedule'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(
    final BuildContext context,
    final ColorScheme colorScheme,
    final String title,
    final String subtitle,
    final IconData icon,
    final Color color,
    final VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 12),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  /// Create a new calendar event
  Future<void> _createEvent(
    final BuildContext context,
    final DateTime date,
  ) async {
    final event = CalendarEvent.create(
      title: 'New Event',
      startTime: date,
      endTime: date.add(const Duration(hours: 1)),
    );
    await CalendarService.instance.addEvent(event);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event created!')));
    }
  }

  /// Create a new task
  Future<void> _createTask(
    final BuildContext context,
    final DateTime date,
  ) async {
    await TaskService.instance.createTask(title: 'New Task', dueDate: date);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task created!')));
    }
  }

  /// Create a new habit
  Future<void> _createHabit(
    final BuildContext context,
    final DateTime date,
  ) async {
    final habit = Habit.create(
      title: 'New Habit',
      description: 'Habit created from calendar',
      recurrence: 'daily',
    );
    await DatabaseService.instance.insertHabit(habit);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Habit created!')));
    }
  }

  void _scheduleHabit(final BuildContext context, final DateTime date) {
    // Show habit selection dialog
    _showHabitSelectionDialog(context, date);
  }

  void _createQuickNote(final BuildContext context, final DateTime date) {
    // Create a quick note as an all-day event
    final event = CalendarEvent.create(
      title: 'Quick Note',
      startTime: date,
      endTime: date,
      description: 'Quick note created from calendar',
      isAllDay: true,
    );

    CalendarService.instance
        .createEvent(
          title: event.title,
          startTime: event.startTime,
          endTime: event.endTime,
          description: event.description,
          category: event.category,
          isAllDay: event.isAllDay,
        )
        .then((_) {
          Navigator.of(context).pop();
          onActionCompleted?.call();
          _showSuccessSnackBar(context, 'Quick note created successfully');
        });
  }

  void _scheduleFromTemplate(final BuildContext context, final DateTime date) {
    // Show template selection dialog
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Schedule from Template'),
        content: const Text(
          'Template functionality will be available soon. '
          'You\'ll be able to create reusable event templates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _bulkSchedule(final BuildContext context, final DateTime date) {
    // Show bulk schedule dialog
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Bulk Schedule'),
        content: const Text(
          'Bulk scheduling will allow you to create multiple events '
          'across several days at once.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHabitSelectionDialog(
    final BuildContext context,
    final DateTime date,
  ) {
    showDialog(
      context: context,
      builder: (final context) => FutureBuilder<List<Habit>>(
        future: DatabaseService.instance.getAllHabits(),
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              title: Text('Loading Habits'),
              content: CircularProgressIndicator(),
            );
          }

          final habits = snapshot.data ?? [];

          if (habits.isEmpty) {
            return AlertDialog(
              title: const Text('No Habits'),
              content: const Text(
                'You haven\'t created any habits yet. '
                'Create habits first to schedule them on the calendar.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Select Habit to Schedule'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: habits.length,
                itemBuilder: (final context, final index) {
                  final habit = habits[index];
                  return ListTile(
                    leading: Icon(
                      Icons.loop,
                      color: habit.color != null
                          ? (habit.color is int
                                ? Color(habit.color! as int)
                                : (habit.color is String
                                      ? Color(
                                          int.parse(habit.color!, radix: 16),
                                        )
                                      : Theme.of(context).colorScheme.primary))
                          : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(habit.name),
                    subtitle: Text(habit.category ?? 'No category'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _scheduleHabitForDate(context, habit, date);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _scheduleHabitForDate(
    final BuildContext context,
    final Habit habit,
    final DateTime date,
  ) {
    CalendarService.instance
        .createEventFromHabit(habit: habit, date: date)
        .then((_) {
          Navigator.of(context).pop();
          onActionCompleted?.call();
          _showSuccessSnackBar(context, 'Habit scheduled successfully');
        });
  }

  void _showSuccessSnackBar(final BuildContext context, final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDate(final DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
