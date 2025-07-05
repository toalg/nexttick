import 'package:flutter/material.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Dialog for creating and editing calendar events
class EventEditorDialog extends StatefulWidget {
  const EventEditorDialog({
    this.selectedDate,
    this.appointment,
    super.key,
  });

  const EventEditorDialog.edit({
    required this.appointment,
    super.key,
  }) : selectedDate = null;

  final DateTime? selectedDate;
  final Appointment? appointment;

  @override
  State<EventEditorDialog> createState() => _EventEditorDialogState();
}

class _EventEditorDialogState extends State<EventEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  EventCategory _category = EventCategory.other;
  EventPriority _priority = EventPriority.medium;
  bool _isAllDay = false;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.appointment != null) {
      // Edit mode
      final appointment = widget.appointment!;
      _titleController.text = appointment.subject;
      _descriptionController.text = appointment.notes ?? '';
      _locationController.text = appointment.location ?? '';
      _startDate = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(appointment.startTime);
      _endDate = DateTime(
        appointment.endTime.year,
        appointment.endTime.month,
        appointment.endTime.day,
      );
      _endTime = TimeOfDay.fromDateTime(appointment.endTime);
      _isAllDay = appointment.isAllDay;
      _selectedColor = appointment.color;
    } else {
      // Create mode
      final date = widget.selectedDate ?? DateTime.now();
      _startDate = date;
      _endDate = date;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildDateTimeSection(context),
                      const SizedBox(height: 16),
                      _buildCategoryPrioritySection(),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                      const SizedBox(height: 16),
                      _buildColorPicker(colorScheme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context, final ColorScheme colorScheme) {
    final isEdit = widget.appointment != null;
    
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
            isEdit ? Icons.edit : Icons.add,
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
                isEdit ? 'Edit Event' : 'New Event',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isEdit ? 'Modify event details' : 'Create a new calendar event',
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

  Widget _buildTitleField() => TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Event Title',
        hintText: 'Enter event title',
        prefixIcon: Icon(Icons.title),
      ),
      validator: (final value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an event title';
        }
        return null;
      },
    );

  Widget _buildDescriptionField() => TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Enter event description',
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 2,
    );

  Widget _buildDateTimeSection(final BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule),
            const SizedBox(width: 8),
            Text(
              'Date & Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Row(
              children: [
                const Text('All Day'),
                Switch(
                  value: _isAllDay,
                  onChanged: (final value) {
                    setState(() {
                      _isAllDay = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                'Start Date',
                _startDate,
                (final date) => setState(() => _startDate = date),
              ),
            ),
            if (!_isAllDay) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  context,
                  'Start Time',
                  _startTime,
                  (final time) => setState(() => _startTime = time),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                'End Date',
                _endDate,
                (final date) => setState(() => _endDate = date),
              ),
            ),
            if (!_isAllDay) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  context,
                  'End Time',
                  _endTime,
                  (final time) => setState(() => _endTime = time),
                ),
              ),
            ],
          ],
        ),
      ],
    );

  Widget _buildDatePicker(
    final String label,
    final DateTime date,
    final ValueChanged<DateTime> onChanged,
  ) => InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
        ),
      ),
    );

  Widget _buildTimePicker(
    final BuildContext context,
    final String label,
    final TimeOfDay time,
    final ValueChanged<TimeOfDay> onChanged,
  ) => InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) {
          onChanged(selectedTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(time.format(context)),
      ),
    );

  Widget _buildCategoryPrioritySection() => Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<EventCategory>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
            ),
            items: EventCategory.values.map((final category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      CalendarEvent.getIconForCategory(category),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(category.name.toUpperCase()),
                  ],
                ),
              )).toList(),
            onChanged: (final value) {
              if (value != null) {
                setState(() {
                  _category = value;
                  _selectedColor = CalendarEvent.getDefaultColorForCategory(value);
                });
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<EventPriority>(
            value: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              prefixIcon: Icon(Icons.flag),
            ),
            items: EventPriority.values.map((final priority) => DropdownMenuItem(
                value: priority,
                child: Text(priority.name.toUpperCase()),
              )).toList(),
            onChanged: (final value) {
              if (value != null) {
                setState(() {
                  _priority = value;
                });
              }
            },
          ),
        ),
      ],
    );

  Widget _buildLocationField() => TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location',
        hintText: 'Enter location',
        prefixIcon: Icon(Icons.location_on),
      ),
    );

  Widget _buildNotesField() => TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Additional notes',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );

  Widget _buildColorPicker(final ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.palette),
            const SizedBox(width: 8),
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: colors.map((final color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: colorScheme.onSurface, width: 3)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(final BuildContext context, final ColorScheme colorScheme) => Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(widget.appointment != null ? 'Save' : 'Create'),
          ),
        ),
      ],
    );

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = _isAllDay
          ? _startDate
          : DateTime(
              _startDate.year,
              _startDate.month,
              _startDate.day,
              _startTime.hour,
              _startTime.minute,
            );

      final endDateTime = _isAllDay
          ? _endDate.add(const Duration(days: 1))
          : DateTime(
              _endDate.year,
              _endDate.month,
              _endDate.day,
              _endTime.hour,
              _endTime.minute,
            );

      final event = CalendarEvent.create(
        title: _titleController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        color: _selectedColor,
        isAllDay: _isAllDay,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
      );

      Navigator.of(context).pop(event);
    }
  }
}