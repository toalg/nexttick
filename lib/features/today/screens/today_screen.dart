import 'package:flutter/material.dart';
import 'package:nexttick/core/theme/app_theme.dart';
import 'package:nexttick/shared/models/habit.dart';
import 'package:nexttick/shared/services/database_service.dart';
import 'package:nexttick/shared/widgets/multi_action_fab.dart';

/// Today screen showing today's habits and completion status
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late Future<List<Habit>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    _habitsFuture = DatabaseService.instance.getAllHabits();
  }

  void _onDataChanged() {
    setState(_loadHabits);
  }

  @override
  Widget build(final BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Text(
                _getTodayHeader(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your daily habits to build momentum',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Progress summary with gradient
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Today\'s Progress',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProgressItem(
                            context,
                            '0',
                            'Completed',
                            Icons.check_circle_outline,
                            Colors.white,
                          ),
                          _buildProgressItem(
                            context,
                            '5',
                            'Total',
                            Icons.list_alt,
                            Colors.white.withOpacity(0.8),
                          ),
                          _buildProgressItem(
                            context,
                            '0',
                            'Streak',
                            Icons.local_fire_department,
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Habits list placeholder with vibrant empty state
              Expanded(
                child: FutureBuilder<List<Habit>>(
                  future: _habitsFuture,
                  builder: (final context, final snapshot) {
                    final habits = snapshot.data ?? [];
                    final hasHabits = habits.isNotEmpty;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Vibrant illustration container
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.energeticGradient,
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_task,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            hasHabits
                                ? 'Keep building momentum!'
                                : 'Ready to build momentum?',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasHabits
                                ? 'Add another habit to strengthen your routine'
                                : 'Create your first habit and start your journey\ntowards positive change',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppTheme.successGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // This will be handled by the FAB
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                hasHabits
                                    ? 'Add Another Habit'
                                    : 'Create Your First Habit',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: MultiActionFAB(
        onHabitCreated: _onDataChanged,
        onTaskCreated: _onDataChanged,
        onEventCreated: _onDataChanged,
      ),
    );
  }

  /// Build a progress item widget
  Widget _buildProgressItem(
    final BuildContext context,
    final String value,
    final String label,
    final IconData icon,
    final Color color,
  ) => Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.getColorScheme(context).onSurfaceVariant,
          ),
        ),
      ],
    );

  /// Get today's header text
  String _getTodayHeader() {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    final month = _getMonthName(now.month);
    final day = now.day;

    return '$weekday, $month $day';
  }

  /// Get weekday name
  String _getWeekdayName(final int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  /// Get month name
  String _getMonthName(final int month) {
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
    return months[month - 1];
  }
}
