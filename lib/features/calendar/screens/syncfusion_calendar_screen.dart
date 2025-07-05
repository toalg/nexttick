import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:nexttick/core/theme/app_theme.dart';
import 'package:nexttick/features/calendar/widgets/calendar_view_selector.dart';
import 'package:nexttick/features/calendar/widgets/event_editor_dialog.dart';
import 'package:nexttick/shared/data/calendar_data_source.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:nexttick/shared/services/calendar_service.dart';
import 'package:nexttick/shared/services/task_service.dart';
import 'package:nexttick/shared/widgets/multi_action_fab.dart';
import 'package:nexttick/shared/models/task.dart';

/// Fantastical-style calendar screen using Syncfusion Calendar
class SyncfusionCalendarScreen extends StatefulWidget {
  const SyncfusionCalendarScreen({super.key});

  @override
  State<SyncfusionCalendarScreen> createState() =>
      _SyncfusionCalendarScreenState();
}

class _SyncfusionCalendarScreenState extends State<SyncfusionCalendarScreen> {
  final CalendarService _calendarService = CalendarService.instance;
  final TaskService _taskService = TaskService.instance;
  EventDataSource? _dataSource;
  CalendarView _currentView = CalendarView.month;
  DateTime _focusedDate = DateTime.now();
  final CalendarController _calendarController = CalendarController();
  final List<EventCategory> _visibleCategories = EventCategory.values;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    await _calendarService.initialize();
    final tasks = await _taskService.getAllTasks();
    _dataSource = EventDataSource(_calendarService.events, tasks);
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);

    return Scaffold(
      appBar: _buildAppBar(context, colorScheme),
      body: _buildCalendarBody(context, colorScheme),
      floatingActionButton: MultiActionFAB(onEventCreated: _refreshCalendar),
    );
  }

  /// Refresh calendar data
  Future<void> _refreshCalendar() async {
    final tasks = await _taskService.getAllTasks();
    if (mounted) {
      _dataSource?.updateEvents(_calendarService.events, tasks);
      setState(() {});
    }
  }

  /// Build the app bar with view selector and filters
  PreferredSizeWidget _buildAppBar(
    final BuildContext context,
    final ColorScheme colorScheme,
  ) {
    return AppBar(
      title: const Text('Calendar'),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      actions: [
        // View selector
        CalendarViewSelector(
          currentView: _currentView,
          onViewChanged: (view) {
            setState(() {
              _currentView = view;
            });
          },
        ),

        // Filter button
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showCategoryFilter(context),
          tooltip: 'Filter categories',
        ),

        // Today button
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            _calendarController.displayDate = DateTime.now();
            setState(() {
              _focusedDate = DateTime.now();
            });
          },
          tooltip: 'Go to today',
        ),
      ],
    );
  }

  /// Build the main calendar body
  Widget _buildCalendarBody(
    final BuildContext context,
    final ColorScheme colorScheme,
  ) {
    if (!_isInitialized || _dataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Calendar header with month/year navigation
        _buildCalendarHeader(context, colorScheme),

        // Main calendar widget
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SfCalendar(
                controller: _calendarController,
                view: _currentView,
                dataSource: _dataSource!,
                initialDisplayDate: _focusedDate,

                // Styling
                backgroundColor: colorScheme.surface,
                todayHighlightColor: colorScheme.primary,
                selectionDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  border: Border.all(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),

                // Header styling
                headerStyle: CalendarHeaderStyle(
                  backgroundColor: colorScheme.surface,
                  textStyle: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // View header styling (days of week)
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: colorScheme.surface,
                  dayTextStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Time slot styling
                timeSlotViewSettings: TimeSlotViewSettings(
                  timeTextStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  timelineAppointmentHeight: 50,
                ),

                // Event interactions
                onTap: _handleCalendarTap,
                onLongPress: _handleCalendarLongPress,
                onDragEnd: _handleDragEnd,
                onViewChanged: _handleViewChanged,

                // Enable drag and drop
                allowDragAndDrop: true,

                // Show navigation arrows
                showNavigationArrow: true,

                // Month view settings
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  showAgenda: false,
                  appointmentDisplayCount: 4,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: colorScheme.surface,
                    textStyle: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    trailingDatesTextStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 14,
                    ),
                    leadingDatesTextStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 14,
                    ),
                  ),
                ),

                // Week view settings
                weekNumberStyle: WeekNumberStyle(
                  backgroundColor: colorScheme.surface,
                  textStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build calendar header with navigation
  Widget _buildCalendarHeader(
    final BuildContext context,
    final ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Month/Year display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMonthYear(_focusedDate),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                if (_currentView == CalendarView.month) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_getEventsCountForMonth(_focusedDate)} events this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _navigateCalendar(-1),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _navigateCalendar(1),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build floating action button for creating events

  /// Handle calendar tap events
  void _handleCalendarTap(final CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final appointment =
          details.appointments != null && details.appointments!.isNotEmpty
          ? details.appointments!.first as Appointment
          : null;
      if (appointment != null) {
        // Check if this is a task (by checking if subject starts with 📋)
        if (appointment.subject.startsWith('📋')) {
          _handleTaskTap(appointment);
        } else {
          _editEvent(context, appointment);
        }
      }
    } else if (details.targetElement == CalendarElement.calendarCell) {
      if (details.date != null) {
        _onCalendarCellTap(details.date!);
      }
    }
  }

  /// Handle calendar long press events
  void _handleCalendarLongPress(final CalendarLongPressDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final appointment =
          details.appointments != null && details.appointments!.isNotEmpty
          ? details.appointments!.first as Appointment
          : null;
      if (appointment != null) {
        // Fallback: use Offset.zero for context menu position
        _showEventContextMenu(context, appointment, Offset.zero);
      }
    }
  }

  /// Handle drag and drop events
  void _handleDragEnd(final AppointmentDragEndDetails details) {
    if (details.appointment != null && details.appointment is Appointment) {
      _moveEvent(details.appointment! as Appointment, details.droppingTime!);
    }
  }

  /// Handle view changes
  void _handleViewChanged(ViewChangedDetails details) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _focusedDate = details.visibleDates.first;
        });
      }
    });
  }

  /// Navigate calendar by specified months
  void _navigateCalendar(int months) {
    final newDate = DateTime(
      _focusedDate.year,
      _focusedDate.month + months,
      _focusedDate.day,
    );
    _calendarController.displayDate = newDate;
    setState(() {
      _focusedDate = newDate;
    });
  }

  /// Format month and year for display
  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Get events count for current month
  int _getEventsCountForMonth(DateTime date) {
    final monthEvents = _calendarService.getEventsForDateRange(
      startDate: DateTime(date.year, date.month, 1),
      endDate: DateTime(date.year, date.month + 1, 0),
    );
    return monthEvents.length;
  }

  /// Create a new event
  void _createNewEvent(BuildContext context, {DateTime? selectedDate}) {
    showDialog<CalendarEvent>(
      context: context,
      builder: (context) =>
          EventEditorDialog(selectedDate: selectedDate ?? DateTime.now()),
    ).then((event) {
      if (event != null) {
        _calendarService
            .createEvent(
              title: event.title,
              startTime: event.startTime,
              endTime: event.endTime,
              description: event.description,
              category: event.category,
              priority: event.priority,
              location: event.location,
              notes: event.notes,
              isAllDay: event.isAllDay,
            )
            .then((newEvent) {
              if (mounted) {
                setState(() {
                  _dataSource?.addEvent(newEvent);
                });
              }
            });
      }
    });
  }

  /// Edit an existing event
  void _editEvent(final BuildContext context, final Appointment appointment) {
    showDialog<CalendarEvent>(
      context: context,
      builder: (context) => EventEditorDialog.edit(appointment: appointment),
    ).then((updatedEvent) {
      if (updatedEvent != null) {
        _calendarService.updateEvent(updatedEvent).then((event) {
          if (mounted) {
            setState(() {
              _dataSource?.updateEvents(_calendarService.events);
            });
          }
        });
      }
    });
  }

  /// Move an event to a new time
  void _moveEvent(Appointment appointment, DateTime newStartTime) {
    final eventId = appointment.id.toString();
    _calendarService
        .moveEvent(eventId: eventId, newStartTime: newStartTime)
        .then((movedEvent) {
          if (mounted) {
            setState(() {
              _dataSource?.updateEvents(_calendarService.events);
            });
          }
          // Show snackbar confirmation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Event moved to ${_formatEventTime(newStartTime)}',
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Implement undo functionality
                  },
                ),
              ),
            );
          }
        });
  }

  /// Show event context menu
  void _showEventContextMenu(
    BuildContext context,
    Appointment appointment,
    Offset position,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: const ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
          onTap: () => _editEvent(context, appointment),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.copy),
            title: Text('Duplicate'),
          ),
          onTap: () => _duplicateEvent(appointment),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
          ),
          onTap: () => _deleteEvent(appointment),
        ),
      ],
    );
  }

  /// Duplicate an event
  void _duplicateEvent(Appointment appointment) {
    // Implementation for duplicating events
  }

  /// Delete an event
  void _deleteEvent(Appointment appointment) {
    final eventId = appointment.id.toString();
    _calendarService.deleteEvent(eventId).then((_) {
      if (mounted) {
        setState(() {
          _dataSource?.updateEvents(_calendarService.events);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event deleted')));
      }
    });
  }

  /// Show category filter dialog
  void _showCategoryFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Categories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EventCategory.values.map((category) {
            return CheckboxListTile(
              title: Text(category.name.toUpperCase()),
              value: _visibleCategories.contains(category),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _visibleCategories.add(category);
                  } else {
                    _visibleCategories.remove(category);
                  }
                });
                Navigator.of(context).pop();
                _updateVisibleEvents();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Update visible events based on category filter
  void _updateVisibleEvents() async {
    final filteredEvents = _calendarService.events
        .where((event) => _visibleCategories.contains(event.category))
        .toList();
    final tasks = await _taskService.getAllTasks();
    if (mounted) {
      setState(() {
        _dataSource?.updateEvents(filteredEvents, tasks);
      });
    }
  }

  /// Handle task tap events
  void _handleTaskTap(final Appointment appointment) {
    final taskId = appointment.id.toString();
    _showTaskCompletionDialog(taskId);
  }

  /// Show task completion dialog
  void _showTaskCompletionDialog(final String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Action'),
        content: const Text('What would you like to do with this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _completeTask(taskId);
              Navigator.of(context).pop();
            },
            child: const Text('Complete'),
          ),
          TextButton(
            onPressed: () {
              _editTask(taskId);
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  /// Complete a task
  void _completeTask(final String taskId) async {
    try {
      await _taskService.completeTask(taskId);
      await _refreshCalendar();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task completed!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error completing task: $e')));
      }
    }
  }

  /// Edit a task
  void _editTask(final String taskId) async {
    try {
      final tasks = await _taskService.getAllTasks();
      final task = tasks.firstWhere((t) => t.id == taskId);
      // Here you would typically show a task edit dialog
      // For now, we'll just show a message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Edit task: ${task.title}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error finding task: $e')));
      }
    }
  }

  /// Format event time for display
  String _formatEventTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _onCalendarCellTap(DateTime date) async {
    final events = _calendarService.events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
    final tasks = (await _taskService.getAllTasks()).where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => _DayDetailSheet(
        date: date,
        events: events,
        tasks: tasks,
        onTaskComplete: (taskId) async {
          await _completeTask(taskId);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Get color for task based on priority and status
Color _getTaskColor(final Task task) {
  if (task.status == TaskStatus.completed) {
    return const Color(0xFF4CAF50); // Green for completed
  }

  switch (task.priority) {
    case TaskPriority.low:
      return const Color(0xFF9E9E9E); // Grey
    case TaskPriority.medium:
      return const Color(0xFF2196F3); // Blue
    case TaskPriority.high:
      return const Color(0xFFFF9800); // Orange
    case TaskPriority.urgent:
      return const Color(0xFFF44336); // Red
  }
}

/// Convert a task to a calendar appointment
Appointment _taskToAppointment(final Task task) {
  // Tasks are shown as all-day appointments if no due date, or as short blocks if due date is set
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;

  if (task.dueDate != null) {
    // Show task as a 30-minute block at 9 AM on the due date
    startTime = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      9,
      0,
    );
    endTime = startTime.add(const Duration(minutes: 30));
    isAllDay = false;
  } else {
    // Show as all-day task for today
    final today = DateTime.now();
    startTime = DateTime(today.year, today.month, today.day);
    endTime = startTime.add(const Duration(days: 1));
    isAllDay = true;
  }

  return Appointment(
    id: task.id,
    subject: '📋 ${task.title}',
    startTime: startTime,
    endTime: endTime,
    color: _getTaskColor(task),
    isAllDay: isAllDay,
    notes: task.description,
    // Add custom properties for task identification
    resourceIds: ['task'],
  );
}

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({
    super.key,
    required this.date,
    required this.events,
    required this.tasks,
    required this.onTaskComplete,
  });

  final DateTime date;
  final List<CalendarEvent> events;
  final List tasks;
  final void Function(String taskId) onTaskComplete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (events.isNotEmpty) ...[
              _buildSectionHeader(context, 'Events', Icons.event),
              const SizedBox(height: 8),
              ...events.map((event) => _buildEventTile(context, event)),
              const SizedBox(height: 16),
            ],
            if (tasks.isNotEmpty) ...[
              _buildSectionHeader(context, 'Tasks', Icons.task),
              const SizedBox(height: 8),
              ...tasks.map((task) => _buildTaskTile(context, task)),
            ],
            if (events.isEmpty && tasks.isEmpty) _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEventTile(BuildContext context, CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.color,
          child: const Icon(Icons.event, color: Colors.white, size: 16),
        ),
        title: Text(event.title),
        subtitle: Text(
          '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - '
          '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, task) {
    final isCompleted = task.status == TaskStatus.completed;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: isCompleted
              ? null
              : (_) => onTaskComplete(task.id as String),
        ),
        title: Text(
          task.title as String,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: Text(
          (task.description ?? '') as String,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        trailing: _priorityFlag(task.priority),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No events or tasks for this day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add something new',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityFlag(priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Icon(Icons.flag, color: Color(0xFF9E9E9E));
      case TaskPriority.medium:
        return const Icon(Icons.flag, color: Color(0xFF2196F3));
      case TaskPriority.high:
        return const Icon(Icons.flag, color: Color(0xFFFF9800));
      case TaskPriority.urgent:
        return const Icon(Icons.flag, color: Color(0xFFF44336));
      default:
        return const SizedBox.shrink();
    }
  }
}
