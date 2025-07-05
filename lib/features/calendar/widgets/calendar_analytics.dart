import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/calendar_event.dart';
import '../../../shared/models/habit.dart';
import '../../../shared/models/habit_completion.dart';
import '../../../shared/models/task.dart';
import '../../../shared/services/calendar_service.dart';
import '../../../shared/services/database_service.dart';

/// Calendar analytics widget showing productivity insights
class CalendarAnalytics extends StatefulWidget {
  const CalendarAnalytics({
    this.startDate,
    this.endDate,
    super.key,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<CalendarAnalytics> createState() => _CalendarAnalyticsState();
}

class _CalendarAnalyticsState extends State<CalendarAnalytics> {
  final CalendarService _calendarService = CalendarService.instance;
  final DatabaseService _database = DatabaseService.instance;
  
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _loadAnalytics();
  }

  void _initializeDates() {
    final now = DateTime.now();
    _endDate = widget.endDate ?? now;
    _startDate = widget.startDate ?? now.subtract(const Duration(days: 30));
  }

  Future<void> _loadAnalytics() async {
    try {
      final events = _calendarService.getEventsForDateRange(
        startDate: _startDate,
        endDate: _endDate,
      );
      
      final habits = await _database.getAllHabits();
      final completions = await _database.getHabitCompletions(DateTime.now());
      final tasks = await _database.getAllTasks();
      
      final analytics = _calculateAnalytics(events, habits, completions, tasks);
      
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analytics = {};
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _calculateAnalytics(
    List<CalendarEvent> events,
    List<Habit> habits,
    List<HabitCompletion> completions,
    List<Task> tasks,
  ) {
    final totalDays = _endDate.difference(_startDate).inDays + 1;
    
    // Event analytics
    final totalEvents = events.length;
    final completedEvents = events.where((e) => e.isCompleted).length;
    final eventsPerDay = totalEvents / totalDays;
    
    // Category breakdown
    final categoryBreakdown = <EventCategory, int>{};
    for (final event in events) {
      categoryBreakdown[event.category] = 
          (categoryBreakdown[event.category] ?? 0) + 1;
    }
    
    // Habit analytics
    final activeHabits = habits.where((h) => h.isActive).length;
    final habitCompletions = completions.where((c) {
      return c.date.isAfter(_startDate) && c.date.isBefore(_endDate);
    }).length;
    
    // Task analytics
    final tasksInPeriod = tasks.where((t) {
      return t.dueDate != null &&
          t.dueDate!.isAfter(_startDate) &&
          t.dueDate!.isBefore(_endDate);
    }).toList();
    
    final completedTasks = tasksInPeriod
        .where((t) => t.status == TaskStatus.completed)
        .length;
    
    // Productivity metrics
    final busyDays = _calculateBusyDays(events);
    final productiveHours = _calculateProductiveHours(events);
    
    return {
      'totalEvents': totalEvents,
      'completedEvents': completedEvents,
      'eventsPerDay': eventsPerDay,
      'categoryBreakdown': categoryBreakdown,
      'activeHabits': activeHabits,
      'habitCompletions': habitCompletions,
      'tasksInPeriod': tasksInPeriod.length,
      'completedTasks': completedTasks,
      'busyDays': busyDays,
      'productiveHours': productiveHours,
      'totalDays': totalDays,
    };
  }

  int _calculateBusyDays(List<CalendarEvent> events) {
    final daysWithEvents = <String>{};
    for (final event in events) {
      final dateKey = '${event.startTime.year}-${event.startTime.month}-${event.startTime.day}';
      daysWithEvents.add(dateKey);
    }
    return daysWithEvents.length;
  }

  Map<int, int> _calculateProductiveHours(List<CalendarEvent> events) {
    final hourCounts = <int, int>{};
    for (final event in events) {
      if (!event.isAllDay) {
        final hour = event.startTime.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }
    return hourCounts;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);

    if (_isLoading) {
      return _buildLoadingState(colorScheme);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colorScheme),
          const SizedBox(height: 20),
          _buildOverviewCards(context, colorScheme),
          const SizedBox(height: 16),
          _buildCategoryChart(context, colorScheme),
          const SizedBox(height: 16),
          _buildProductivityInsights(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.analytics,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar Analytics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showDetailedAnalytics(context),
          icon: const Icon(Icons.open_in_new),
          tooltip: 'View detailed analytics',
        ),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context, ColorScheme colorScheme) {
    final totalEvents = _analytics['totalEvents'] ?? 0;
    final completedEvents = _analytics['completedEvents'] ?? 0;
    final busyDays = _analytics['busyDays'] ?? 0;
    final totalDays = _analytics['totalDays'] ?? 1;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            colorScheme,
            'Events',
            '$totalEvents',
            '$completedEvents completed',
            Icons.event,
            colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            colorScheme,
            'Active Days',
            '$busyDays/$totalDays',
            '${((busyDays / totalDays) * 100).toStringAsFixed(1)}% coverage',
            Icons.calendar_today,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            colorScheme,
            'Avg/Day',
            '${(_analytics['eventsPerDay'] ?? 0).toStringAsFixed(1)}',
            'events per day',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, ColorScheme colorScheme) {
    final categoryBreakdown = _analytics['categoryBreakdown'] as Map<EventCategory, int>? ?? {};
    
    if (categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events by Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...categoryBreakdown.entries.map((entry) {
          final category = entry.key;
          final count = entry.value;
          final total = categoryBreakdown.values.reduce((a, b) => a + b);
          final percentage = (count / total * 100).toStringAsFixed(1);
          final color = CalendarEvent.getDefaultColorForCategory(category);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.name.toUpperCase(),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$count events ($percentage%)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: count / total,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProductivityInsights(BuildContext context, ColorScheme colorScheme) {
    final productiveHours = _analytics['productiveHours'] as Map<int, int>? ?? {};
    final mostProductiveHour = productiveHours.entries
        .fold<MapEntry<int, int>?>(null, (prev, current) {
      if (prev == null || current.value > prev.value) {
        return current;
      }
      return prev;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productivity Insights',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (mostProductiveHour != null) ...[
          _buildInsightItem(
            context,
            colorScheme,
            'Most Active Hour',
            '${_formatHour(mostProductiveHour.key)} (${mostProductiveHour.value} events)',
            Icons.schedule,
            colorScheme.primary,
          ),
          const SizedBox(height: 8),
        ],
        _buildInsightItem(
          context,
          colorScheme,
          'Habit Completion Rate',
          '${_analytics['habitCompletions'] ?? 0} completions',
          Icons.loop,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildInsightItem(
          context,
          colorScheme,
          'Task Completion Rate',
          '${_analytics['completedTasks'] ?? 0}/${_analytics['tasksInPeriod'] ?? 0} tasks',
          Icons.task_alt,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDetailedAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Analytics'),
        content: const Text(
          'Detailed analytics view will provide in-depth insights '
          'about your productivity patterns, time allocation, and trends.',
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }
}