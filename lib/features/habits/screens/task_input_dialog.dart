import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexttick/core/theme/app_theme.dart';

class TaskInputDialog extends StatefulWidget {
  const TaskInputDialog({super.key, this.onSave});

  final void Function(
    String name,
    String notes,
    DateTime dueDate,
    List<String> tags,
    List<String> subtasks,
    String priority,
  )?
  onSave;

  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _completed = false;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;
  final List<String> _tags = [];
  final List<String> _subtasks = ['']; // Always have at least one row
  String _priority = 'Medium';
  final List<TextEditingController> _subtaskControllers = [];

  @override
  void initState() {
    super.initState();
    _syncSubtaskControllers();
  }

  void _syncSubtaskControllers() {
    // Keep controllers in sync with subtasks
    while (_subtaskControllers.length < _subtasks.length) {
      _subtaskControllers.add(
        TextEditingController(text: _subtasks[_subtaskControllers.length]),
      );
    }
    while (_subtaskControllers.length > _subtasks.length) {
      _subtaskControllers.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    for (final c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSubtaskChanged(final int index, final String value) {
    setState(() {
      _subtasks[index] = value;
      // If editing the last row and it's not empty, add a new row
      if (index == _subtasks.length - 1 && value.trim().isNotEmpty) {
        _subtasks.add('');
        _syncSubtaskControllers();
      }
      // If a row (not last) is cleared, remove it
      if (value.trim().isEmpty && index != _subtasks.length - 1) {
        _subtasks.removeAt(index);
        _syncSubtaskControllers();
      }
    });
  }

  void _onReorderSubtasks(final int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _subtasks.removeAt(oldIndex);
      final controller = _subtaskControllers.removeAt(oldIndex);
      _subtasks.insert(newIndex, item);
      _subtaskControllers.insert(newIndex, controller);
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _showTagDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tag'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeTag(final String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _showPriorityMenu() async {
    final priorities = ['Low', 'Medium', 'High', 'Urgent'];
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(300, 300, 0, 0),
      items: priorities
          .map(
            (final p) => PopupMenuItem<String>(
              value: p,
              child: Row(
                children: [
                  Icon(Icons.flag, color: _priorityColor(p), size: 18),
                  const SizedBox(width: 8),
                  Text(p),
                ],
              ),
            ),
          )
          .toList(),
    );
    if (selected != null) {
      setState(() => _priority = selected);
    }
  }

  Color _priorityColor(final String p) {
    switch (p) {
      case 'Low':
        return Colors.grey;
      case 'Medium':
        return Colors.blue;
      case 'High':
        return Colors.orange;
      case 'Urgent':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final colorScheme = AppTheme.getColorScheme(context);
    final canSave = _nameController.text.trim().isNotEmpty;
    final dateLabel = _dueDate.difference(DateTime.now()).inDays == 1
        ? 'Tomorrow'
        : DateFormat('MMM d').format(_dueDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Semantics(
        label: 'New Task Dialog',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Task',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Create a new task to complete',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _completed,
                      onChanged: (final v) => setState(() => _completed = v ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'New To-Do',
                          border: InputBorder.none,
                          isDense: true,
                          counterText: '',
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                        maxLength: 48,
                        onChanged: (_) => setState(() {}),
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Notes',
                      border: InputBorder.none,
                      isDense: true,
                      counterText: '',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLength: 120,
                    minLines: 1,
                    maxLines: 2,
                  ),
                ),
                if (_tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 40, top: 4),
                    child: Wrap(
                      spacing: 6,
                      children: _tags
                          .map(
                            (final tag) => Chip(
                              label: Text(tag),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: colorScheme.primaryContainer,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                // Inline editable, reorderable subtasks
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: _onReorderSubtasks,
                    buildDefaultDragHandles: false,
                    children: List.generate(_subtasks.length, (final i) {
                      final isLast = i == _subtasks.length - 1;
                      return Material(
                        key: ValueKey('subtask_$i'),
                        color: isLast && _subtasks[i].isEmpty
                            ? colorScheme.surfaceContainerHighest.withOpacity(0.2)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            const Icon(Icons.radio_button_unchecked, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _subtaskControllers[i],
                                onChanged: (final v) => _onSubtaskChanged(i, v),
                                onSubmitted: (final v) => _onSubtaskChanged(i, v),
                                decoration: const InputDecoration(
                                  hintText: 'Sub-task',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: Theme.of(context).textTheme.bodyLarge,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_handle, size: 20),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.pink, size: 22),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _pickDueDate,
                        child: Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.local_offer_outlined),
                        tooltip: 'Add tags',
                        onPressed: _showTagDialog,
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.flag,
                              color: _priorityColor(_priority),
                            ),
                            tooltip: 'Set priority',
                            onPressed: _showPriorityMenu,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: 'Save Task',
                    button: true,
                    child: ElevatedButton(
                      onPressed: canSave && !_saving
                          ? () async {
                              setState(() => _saving = true);
                              final subtasks = _subtasks
                                  .where((final s) => s.trim().isNotEmpty)
                                  .toList();
                              widget.onSave?.call(
                                _nameController.text.trim(),
                                _notesController.text.trim(),
                                _dueDate,
                                _tags,
                                subtasks,
                                _priority,
                              );
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
