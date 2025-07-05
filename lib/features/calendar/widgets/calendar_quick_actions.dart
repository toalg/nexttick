import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/calendar_event.dart';
import '../../../shared/models/habit.dart';
import '../../../shared/models/task.dart';
import '../../../shared/services/calendar_service.dart';
import '../../../shared/services/task_service.dart';
import '../../../shared/services/database_service.dart';

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
  Widget build(BuildContext context) {
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
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
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
  }

  void _createEvent(BuildContext context, DateTime date) {
    // Create a simple event for the selected date
    final event = CalendarEvent.create(
      title: 'New Event',
      startTime: DateTime(date.year, date.month, date.day, 9, 0),
      endTime: DateTime(date.year, date.month, date.day, 10, 0),
      description: 'Event created from quick actions',
      category: EventCategory.personal,
    );

    CalendarService.instance
        .createEvent(
          title: event.title,
          startTime: event.startTime,
          endTime: event.endTime,
          description: event.description,
          category: event.category,
        )
        .then((_) {
          Navigator.of(context).pop();
          onActionCompleted?.call();
          _showSuccessSnackBar(context, 'Event created successfully');
        });
  }

  void _createTask(BuildContext context, DateTime date) {
    // Create a task with the selected date as due date
    TaskService.instance
        .createTask(
          title: 'New Task',
          description: 'Task created from calendar',
          dueDate: date,
          priority: TaskPriority.medium,
        )
        .then((_) {
          Navigator.of(context).pop();
          onActionCompleted?.call();
          _showSuccessSnackBar(context, 'Task created successfully');
        });
  }

  void _scheduleHabit(BuildContext context, DateTime date) {
    // Show habit selection dialog
    _showHabitSelectionDialog(context, date);
  }

  void _createQuickNote(BuildContext context, DateTime date) {
    // Create a quick note as an all-day event
    final event = CalendarEvent.create(
      title: 'Quick Note',
      startTime: date,
      endTime: date,
      description: 'Quick note created from calendar',
      category: EventCategory.other,
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

  void _scheduleFromTemplate(BuildContext context, DateTime date) {
    // Show template selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _bulkSchedule(BuildContext context, DateTime date) {
    // Show bulk schedule dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _showHabitSelectionDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Habit>>(
        future: DatabaseService.instance.getAllHabits(),
        builder: (context, snapshot) {
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
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return ListTile(
                    leading: Icon(
                      Icons.loop,
                      color: habit.color != null
                          ? (habit.color is int
                                ? Color(habit.color as int)
                                : (habit.color is String
                                      ? Color(
                                          int.parse(
                                            habit.color as String,
                                            radix: 16,
                                          ),
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

  void _scheduleHabitForDate(BuildContext context, Habit habit, DateTime date) {
    CalendarService.instance
        .createEventFromHabit(habit: habit, date: date)
        .then((_) {
          Navigator.of(context).pop();
          onActionCompleted?.call();
          _showSuccessSnackBar(context, 'Habit scheduled successfully');
        });
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
