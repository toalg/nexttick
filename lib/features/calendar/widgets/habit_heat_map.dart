import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexttick/core/theme/app_theme.dart';
import 'package:nexttick/shared/models/habit.dart';
import 'package:nexttick/shared/models/habit_completion.dart';
import 'package:nexttick/shared/services/database_service.dart';

/// GitHub-style heat map widget for showing habit completion streaks
class HabitHeatMap extends StatefulWidget {
  const HabitHeatMap({
    required this.habit,
    this.startDate,
    this.endDate,
    super.key,
  });

  final Habit habit;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<HabitHeatMap> createState() => _HabitHeatMapState();
}

class _HabitHeatMapState extends State<HabitHeatMap> {
  final DatabaseService _database = DatabaseService.instance;
  List<HabitCompletion> _completions = [];
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _loadCompletions();
  }

  void _initializeDates() {
    final now = DateTime.now();
    _endDate = widget.endDate ?? now;
    _startDate = widget.startDate ?? now.subtract(const Duration(days: 365));
  }

  Future<void> _loadCompletions() async {
    try {
      final completions = await _database.getCompletionsByHabitId(
        widget.habit.id,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          _completions = completions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _completions = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
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
          const SizedBox(height: 16),
          _buildHeatMap(context, colorScheme),
          const SizedBox(height: 12),
          _buildLegend(context, colorScheme),
          const SizedBox(height: 12),
          _buildStats(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildLoadingState(final ColorScheme colorScheme) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );

  Widget _buildHeader(final BuildContext context, final ColorScheme colorScheme) => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_fire_department,
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
                '${widget.habit.name} Streak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Past ${_endDate.difference(_startDate).inDays} days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${_getCurrentStreak()} day streak',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

  Widget _buildHeatMap(final BuildContext context, final ColorScheme colorScheme) {
    const cellSize = 12.0;
    const cellSpacing = 2.0;
    const daysInWeek = 7;

    final totalDays = _endDate.difference(_startDate).inDays + 1;
    final weeks = (totalDays / daysInWeek).ceil();

    return SizedBox(
      height: (cellSize + cellSpacing) * daysInWeek,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(weeks, (final weekIndex) => Column(
              children: List.generate(daysInWeek, (final dayIndex) {
                final dayOffset = weekIndex * daysInWeek + dayIndex;
                final date = _startDate.add(Duration(days: dayOffset));

                if (date.isAfter(_endDate)) {
                  return const SizedBox(width: cellSize, height: cellSize);
                }

                return _buildHeatMapCell(
                  context,
                  colorScheme,
                  date,
                  _getCompletionForDate(date),
                );
              }),
            )),
        ),
      ),
    );
  }

  Widget _buildHeatMapCell(
    final BuildContext context,
    final ColorScheme colorScheme,
    final DateTime date,
    final HabitCompletion? completion,
  ) {
    final intensity = completion != null ? 1.0 : 0.0;
    final color = _getIntensityColor(colorScheme, intensity);

    return GestureDetector(
      onTap: () {
        if (completion != null) {
          _showCompletionDetails(context, date, completion);
        }
      },
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: completion != null
            ? const Icon(Icons.check, size: 12, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildLegend(final BuildContext context, final ColorScheme colorScheme) => Row(
      children: [
        Text(
          'Less',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(5, (final index) {
            final color = _getColorForIntensity(colorScheme, index / 4);
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          'More',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );

  Widget _buildStats(final BuildContext context, final ColorScheme colorScheme) {
    final totalCompletions = _completions.length;
    final totalDays = _endDate.difference(_startDate).inDays + 1;
    final completionRate = totalDays > 0 ? (totalCompletions / totalDays) : 0.0;
    final currentStreak = _getCurrentStreak();
    final longestStreak = _getLongestStreak();

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            colorScheme,
            'Completion Rate',
            '${(completionRate * 100).toStringAsFixed(1)}%',
            Icons.percent,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            colorScheme,
            'Current Streak',
            '$currentStreak days',
            Icons.local_fire_department,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            colorScheme,
            'Best Streak',
            '$longestStreak days',
            Icons.emoji_events,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    final BuildContext context,
    final ColorScheme colorScheme,
    final String label,
    final String value,
    final IconData icon,
  ) => Column(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );

  HabitCompletion? _getCompletionForDate(final DateTime date) => _completions.firstWhere((final completion) {
      final completionDate = DateTime(
        completion.date.year,
        completion.date.month,
        completion.date.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return completionDate.isAtSameMomentAs(checkDate);
    }, orElse: () => null as HabitCompletion);

  double _getIntensityForDate(final DateTime date, final HabitCompletion? completion) {
    if (completion == null) return 0;

    // Calculate intensity based on completion count and target
    final ratio = completion.completionCount / widget.habit.targetCount;
    return ratio.clamp(0.0, 2.0) / 2.0; // Scale to 0-1 range
  }

  Color _getColorForIntensity(final ColorScheme colorScheme, final double intensity) {
    if (intensity == 0.0) {
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }

    final baseColor = colorScheme.primary;
    return Color.lerp(baseColor.withValues(alpha: 0.2), baseColor, intensity)!;
  }

  int _getCurrentStreak() {
    if (_completions.isEmpty) return 0;

    final now = DateTime.now();
    var streakCount = 0;

    for (var i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasCompletion = _completions.any((final completion) {
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
        streakCount++;
      } else {
        break;
      }
    }

    return streakCount;
  }

  int _getLongestStreak() {
    if (_completions.isEmpty) return 0;

    // Sort completions by date
    final sortedCompletions = List<HabitCompletion>.from(_completions)
      ..sort((final a, final b) => a.date.compareTo(b.date));

    var longestStreak = 0;
    var currentStreak = 0;
    DateTime? lastDate;

    for (final completion in sortedCompletions) {
      final currentDate = DateTime(
        completion.date.year,
        completion.date.month,
        completion.date.day,
      );

      if (lastDate == null || currentDate.difference(lastDate).inDays == 1) {
        currentStreak++;
      } else if (currentDate.difference(lastDate).inDays > 1) {
        longestStreak = longestStreak > currentStreak
            ? longestStreak
            : currentStreak;
        currentStreak = 1;
      }

      lastDate = currentDate;
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  /// Get color for intensity level
  Color _getIntensityColor(
    final ColorScheme colorScheme,
    final double intensity,
  ) {
    if (intensity == 0.0) {
      return colorScheme.surfaceContainerHighest;
    }

    final baseColor = colorScheme.primary;
    final alpha = intensity;
    return baseColor.withValues(alpha: alpha);
  }

  /// Show completion details dialog
  void _showCompletionDetails(
    final BuildContext context,
    final DateTime date,
    final HabitCompletion completion,
  ) {
    showDialog<void>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: const Text('Completion Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMM dd, yyyy').format(date)}'),
            Text('Notes: ${completion.notes ?? 'No notes'}'),
          ],
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
}
