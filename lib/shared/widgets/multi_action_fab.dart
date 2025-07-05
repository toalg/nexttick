import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/habits/screens/habit_input_dialog.dart';
import '../../features/habits/screens/task_input_dialog.dart';
import '../../features/calendar/widgets/event_editor_dialog.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../models/calendar_event.dart';
import '../services/database_service.dart';

/// Multi-action FAB with smooth popup for creating habits, tasks, and events
class MultiActionFAB extends StatefulWidget {
  const MultiActionFAB({
    super.key,
    this.onHabitCreated,
    this.onTaskCreated,
    this.onEventCreated,
  });

  final VoidCallback? onHabitCreated;
  final VoidCallback? onTaskCreated;
  final VoidCallback? onEventCreated;

  @override
  State<MultiActionFAB> createState() => _MultiActionFABState();
}

class _MultiActionFABState extends State<MultiActionFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showHabitDialog() async {
    _toggleExpanded();
    await showDialog<Habit>(
      context: context,
      builder: (context) => HabitInputDialog(
        onSave: (habit) async {
          await DatabaseService.instance.insertHabit(habit);
          widget.onHabitCreated?.call();
        },
      ),
    );
  }

  void _showTaskDialog() async {
    _toggleExpanded();
    await showDialog<Task>(
      context: context,
      builder: (context) => TaskInputDialog(
        onSave: (name, notes, dueDate, tags, subtasks, priority) async {
          final task = Task.create(
            title: name,
            description: notes,
            dueDate: dueDate,
          );
          await DatabaseService.instance.insertTask(task);
          widget.onTaskCreated?.call();
        },
      ),
    );
  }

  void _showEventDialog() async {
    _toggleExpanded();
    final event = await showDialog<CalendarEvent>(
      context: context,
      builder: (context) => EventEditorDialog(selectedDate: DateTime.now()),
    );
    if (event != null) {
      await DatabaseService.instance.insertCalendarEvent(event);
      widget.onEventCreated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
          ),

        // Action buttons
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Calendar Event button
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildActionButton(
                      icon: Icons.event,
                      label: 'New Calendar Event',
                      onPressed: _showEventDialog,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Habit button
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildActionButton(
                      icon: Icons.self_improvement,
                      label: 'New Habit',
                      onPressed: _showHabitDialog,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task button
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildActionButton(
                      icon: Icons.task_alt,
                      label: 'New Task',
                      onPressed: _showTaskDialog,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: _isExpanded ? 8 : 6,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Button
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          foregroundColor: Colors.white,
          mini: true,
          heroTag: label,
          child: Icon(icon),
        ),
      ],
    );
  }
}
