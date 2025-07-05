import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/habit.dart';
import '../../../shared/models/habit_completion.dart';
import '../../../shared/services/database_service.dart';

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
  }

  Widget _buildHeatMap(BuildContext context, ColorScheme colorScheme) {
    const cellSize = 12.0;
    const cellSpacing = 2.0;
    const daysInWeek = 7;
    
    final totalDays = _endDate.difference(_startDate).inDays + 1;
    final weeks = (totalDays / daysInWeek).ceil();
    
    return Container(
      height: (cellSize + cellSpacing) * daysInWeek,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(weeks, (weekIndex) {
            return Column(
              children: List.generate(daysInWeek, (dayIndex) {
                final dayOffset = weekIndex * daysInWeek + dayIndex;
                final date = _startDate.add(Duration(days: dayOffset));
                
                if (date.isAfter(_endDate)) {
                  return SizedBox(
                    width: cellSize,
                    height: cellSize,
                  );
                }
                
                return _buildHeatMapCell(
                  context,
                  colorScheme,
                  date,
                  cellSize,
                  cellSpacing,
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeatMapCell(
    BuildContext context,
    ColorScheme colorScheme,
    DateTime date,
    double cellSize,
    double cellSpacing,
  ) {
    final completion = _getCompletionForDate(date);
    final intensity = _getIntensityForDate(date, completion);
    final color = _getColorForIntensity(colorScheme, intensity);
    
    return Container(
      width: cellSize,
      height: cellSize,
      margin: EdgeInsets.only(
        right: cellSpacing,
        bottom: cellSpacing,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showDayDetail(context, date, completion),
        borderRadius: BorderRadius.circular(2),
        child: completion != null && completion.completionCount > 1
            ? Center(
                child: Text(
                  '${completion.completionCount}',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(5, (index) {
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, ColorScheme colorScheme) {
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
    BuildContext context,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  HabitCompletion? _getCompletionForDate(DateTime date) {
    return _completions.firstWhere(
      (completion) {
        final completionDate = DateTime(
          completion.date.year,
          completion.date.month,
          completion.date.day,
        );
        final checkDate = DateTime(date.year, date.month, date.day);
        return completionDate.isAtSameMomentAs(checkDate);
      },
      orElse: () => null as HabitCompletion,
    );
  }

  double _getIntensityForDate(DateTime date, HabitCompletion? completion) {
    if (completion == null) return 0.0;
    
    // Calculate intensity based on completion count and target
    final ratio = completion.completionCount / widget.habit.targetCount;
    return (ratio.clamp(0.0, 2.0) / 2.0); // Scale to 0-1 range
  }

  Color _getColorForIntensity(ColorScheme colorScheme, double intensity) {
    if (intensity == 0.0) {
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
    
    final baseColor = colorScheme.primary;
    return Color.lerp(
      baseColor.withValues(alpha: 0.2),
      baseColor,
      intensity,
    )!;
  }

  int _getCurrentStreak() {
    if (_completions.isEmpty) return 0;
    
    final now = DateTime.now();
    var streakCount = 0;
    
    for (var i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasCompletion = _completions.any((completion) {
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
      ..sort((a, b) => a.date.compareTo(b.date));
    
    var longestStreak = 0;
    var currentStreak = 0;
    DateTime? lastDate;
    
    for (final completion in sortedCompletions) {
      final currentDate = DateTime(
        completion.date.year,
        completion.date.month,
        completion.date.day,
      );
      
      if (lastDate == null || 
          currentDate.difference(lastDate).inDays == 1) {
        currentStreak++;
      } else if (currentDate.difference(lastDate).inDays > 1) {
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
        currentStreak = 1;
      }
      
      lastDate = currentDate;
    }
    
    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  void _showDayDetail(
    BuildContext context,
    DateTime date,
    HabitCompletion? completion,
  ) {
    final colorScheme = AppTheme.getColorScheme(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${widget.habit.name}',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (completion != null) ...[
              Text(
                'Completed ${completion.completionCount} times',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (completion.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${completion.notes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'No completion recorded',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}