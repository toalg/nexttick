import 'package:flutter/material.dart';
import 'package:nexttick/shared/models/calendar_event.dart';
import 'package:nexttick/shared/models/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Custom data source for Syncfusion Calendar
class EventDataSource extends CalendarDataSource {
  /// Constructor with initial events and tasks
  EventDataSource(final List<CalendarEvent> events, [final List<Task> tasks = const []]) {
    appointments = [
      ...events.map((final event) => event.toAppointment()),
      ...tasks.map(_taskToAppointment),
    ];
  }

  /// Update all events and tasks
  void updateEvents(final List<CalendarEvent> events, [final List<Task> tasks = const []]) {
    appointments!.clear();
    appointments!.addAll([
      ...events.map((final event) => event.toAppointment()),
      ...tasks.map(_taskToAppointment),
    ]);
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  /// Add a single event
  void addEvent(final CalendarEvent event) {
    appointments!.add(event.toAppointment());
    notifyListeners(CalendarDataSourceAction.add, [event.toAppointment()]);
  }

  /// Update an existing event
  void updateEvent(final CalendarEvent oldEvent, final CalendarEvent newEvent) {
    final index = appointments!.indexWhere(
      (final appointment) => appointment.id == oldEvent.id,
    );
    
    if (index != -1) {
      appointments![index] = newEvent.toAppointment();
      notifyListeners(CalendarDataSourceAction.reset, appointments!);
    }
  }

  /// Remove an event
  void removeEvent(final CalendarEvent event) {
    appointments!.removeWhere(
      (final appointment) => appointment.id == event.id,
    );
    notifyListeners(CalendarDataSourceAction.remove, [event.toAppointment()]);
  }

  /// Add a single task
  void addTask(final Task task) {
    appointments!.add(_taskToAppointment(task));
    notifyListeners(CalendarDataSourceAction.add, [_taskToAppointment(task)]);
  }

  /// Update an existing task
  void updateTask(final Task oldTask, final Task newTask) {
    final index = appointments!.indexWhere(
      (final appointment) => appointment.id == oldTask.id,
    );
    
    if (index != -1) {
      appointments![index] = _taskToAppointment(newTask);
      notifyListeners(CalendarDataSourceAction.reset, appointments!);
    }
  }

  /// Remove a task
  void removeTask(final Task task) {
    appointments!.removeWhere(
      (final appointment) => appointment.id == task.id,
    );
    notifyListeners(CalendarDataSourceAction.remove, [_taskToAppointment(task)]);
  }

  /// Get all events as CalendarEvent objects
  List<CalendarEvent> get calendarEvents {
    // This is a simplified approach - in a real app you'd maintain 
    // a separate list of CalendarEvent objects
    return [];
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
    );
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
}