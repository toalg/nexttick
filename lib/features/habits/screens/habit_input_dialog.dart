import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/habit.dart';

/// Dialog for creating a new habit with icon, color, and details
class HabitInputDialog extends StatefulWidget {
  const HabitInputDialog({super.key, this.onSave});

  final void Function(Habit habit)? onSave;

  @override
  State<HabitInputDialog> createState() => _HabitInputDialogState();
}

class _HabitInputDialogState extends State<HabitInputDialog> {
  static const List<IconData> _icons = [
    Icons.favorite,
    Icons.book,
    Icons.fitness_center,
    Icons.music_note,
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.nature,
    Icons.school,
    Icons.work,
    Icons.pets,
    Icons.self_improvement,
    Icons.brush,
    Icons.sports_soccer,
    Icons.local_cafe,
    Icons.directions_run,
    Icons.local_florist,
    Icons.star,
    Icons.directions_bike,
    Icons.code,
    Icons.attach_money,
    Icons.emoji_events,
    Icons.local_fire_department,
    Icons.nightlight_round,
    Icons.wb_sunny,
    Icons.tv,
    Icons.videogame_asset,
    Icons.flight,
    Icons.restaurant,
    Icons.smoking_rooms,
    Icons.spa,
    Icons.local_library,
    Icons.movie,
    Icons.camera_alt,
    Icons.healing,
  ];
  static const List<Color> _colors = [
    Color(0xFFFB7185),
    Color(0xFFF59E42),
    Color(0xFFFACC15),
    Color(0xFF4ADE80),
    Color(0xFF22D3EE),
    Color(0xFF60A5FA),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
    Color(0xFFF87171),
    Color(0xFF94A3B8),
    Color(0xFFD1D5DB),
  ];

  int _selectedIcon = 0;
  int _selectedColor = 0;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _showAdvanced = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSave = _nameController.text.trim().isNotEmpty;

    final dialogWidth = MediaQuery.of(context).size.width * 0.33;
    final colorBoxSize = 36.0;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, colorScheme),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon picker
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _icons.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => setState(() => _selectedIcon = i),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: i == _selectedIcon
                                ? colorScheme.primary.withOpacity(0.2)
                                : colorScheme.surfaceVariant,
                            child: Icon(
                              _icons[i],
                              color: i == _selectedIcon
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      maxLength: 32,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    // Description
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      maxLength: 64,
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    // Color picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Color',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 1,
                          ),
                      itemCount: _colors.length,
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = i),
                        child: Container(
                          width: colorBoxSize,
                          height: colorBoxSize,
                          decoration: BoxDecoration(
                            color: _colors[i],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: i == _selectedColor
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: i == _selectedColor
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Advanced options
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showAdvanced = !_showAdvanced),
                      child: Row(
                        children: [
                          Text(
                            'Advanced Options',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Icon(
                            _showAdvanced
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    if (_showAdvanced) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'More options coming soon...',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        label: 'Save Habit',
                        button: true,
                        child: ElevatedButton(
                          onPressed: canSave && !_saving
                              ? () async {
                                  setState(() => _saving = true);
                                  final habit = Habit.create(
                                    title: _nameController.text.trim(),
                                    description: _descController.text.trim(),
                                    recurrence: HabitRecurrence.daily,
                                    color: _colors[_selectedColor].value
                                        .toRadixString(16),
                                    icon: _icons[_selectedIcon].codePoint
                                        .toString(),
                                  );
                                  widget.onSave?.call(habit);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add,
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Habit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Create a new habit to track',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
