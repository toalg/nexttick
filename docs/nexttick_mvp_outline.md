# NextTick Enhanced MVP with Calendar Integration

## 📅 Updated MVP Scope (2-Week Sprint)

### Week 1: Foundation & Calendar Integration
**Days 1-2: Project Setup + Calendar**
- Flutter project initialization with calendar dependencies
- Basic app structure with 4 tabs: Today, Calendar, Habits, Progress
- Calendar widget integration (table_calendar package)
- Database schema with date-aware models

**Days 3-4: Habit Management with Calendar**
- Habit creation with recurrence patterns (daily, weekly, custom)
- Calendar integration showing habit schedules
- Habit completion with calendar date tracking
- Visual indicators for completed/pending habits on calendar

**Days 5-7: Task Management with Due Dates**
- Task creation with due date selection
- Calendar integration showing task deadlines
- Task completion with calendar updates
- Priority-based visual indicators on calendar

### Week 2: Calendar Views & Polish
**Days 8-9: Today View + Calendar Month View**
- "Today" dashboard with agenda-style layout
- Calendar month view with habit/task indicators
- Navigation between calendar and detail views
- Quick actions from calendar (mark complete, reschedule)

**Days 10-11: Progress Tracking with Calendar**
- Calendar heat map for habit streaks
- Monthly completion rate visualization
- Weekly progress summary in calendar
- Calendar-based analytics and insights

**Days 12-14: Polish & Calendar UX**
- Calendar animations and transitions
- Swipe gestures for month navigation
- Calendar customization (themes, colors)
- Performance optimization for calendar rendering

## 📱 Updated Screen Structure (4 Core Screens)

### 1. Today View (Primary Dashboard)
- **Agenda Layout**: Today's habits and tasks in chronological order
- **Quick Actions**: One-tap completion, reschedule, add new
- **Progress Summary**: Daily completion percentage, streak status
- **Calendar Integration**: Mini calendar widget with quick navigation

### 2. Calendar View (Month/Week)
- **Month View**: Full calendar with visual indicators
  - 🟢 Completed habits (green dots)
  - 🔴 Pending habits (red dots)
  - 📋 Tasks (colored by priority)
  - 🔥 Streak indicators
- **Week View**: Compact weekly overview
- **Day Detail**: Tap any date to see full agenda

### 3. Habits Management
- **Habit List**: All habits with recurrence patterns
- **Calendar Integration**: Visual schedule preview
- **Habit Creation**: Enhanced with calendar date picker
- **Streak Visualization**: Calendar-based streak tracking

### 4. Progress & Analytics
- **Calendar Heat Map**: GitHub-style contribution calendar
- **Monthly Statistics**: Completion rates, streak records
- **Trend Analysis**: Calendar-based progress trends
- **Export Options**: Calendar data export

## 🗓️ Calendar-Enhanced Data Models

### Enhanced Habit Model
```dart
class Habit {
  final String id;
  final String title;
  final String description;
  final HabitRecurrence recurrence;
  final DateTime createdAt;
  final DateTime? endDate;
  final List<DateTime> customSchedule; // For custom patterns
  final bool isActive;
  
  const Habit({
    required this.id,
    required this.title,
    required this.recurrence,
    required this.createdAt,
    this.description = '',
    this.endDate,
    this.customSchedule = const [],
    this.isActive = true,
  });
}

enum HabitRecurrence {
  daily,
  weekly,
  weekdays, // Monday-Friday
  weekends, // Saturday-Sunday
  custom,   // User-defined pattern
}
```

### Enhanced Task Model
```dart
class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime? dueDate;
  final DateTime? dueTime;
  final bool isCompleted;
  final DateTime createdAt;
  final List<String> tags;
  final String? habitId; // Link to related habit
  
  const Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.createdAt,
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.tags = const [],
    this.habitId,
  });
}
```

### Calendar Event Model
```dart
class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final CalendarEventType type;
  final String? relatedId; // habit_id or task_id
  final bool isCompleted;
  final Priority? priority;
  
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.relatedId,
    this.isCompleted = false,
    this.priority,
  });
}

enum CalendarEventType { habit, task, milestone }
```

## 📊 Enhanced Database Schema

```sql
-- Enhanced habits table with calendar support
CREATE TABLE habits (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  recurrence TEXT NOT NULL, -- daily, weekly, weekdays, weekends, custom
  custom_pattern TEXT, -- JSON for custom recurrence
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  end_date DATETIME,
  is_active BOOLEAN DEFAULT 1
);

-- Enhanced tasks table with due dates
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  priority TEXT DEFAULT 'medium',
  due_date DATE,
  due_time TIME,
  completed BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  habit_id TEXT,
  tags TEXT, -- JSON array
  FOREIGN KEY (habit_id) REFERENCES habits (id)
);

-- Calendar events for unified calendar view
CREATE TABLE calendar_events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_type TEXT NOT NULL, -- habit, task, milestone
  related_id TEXT, -- habit_id or task_id
  is_completed BOOLEAN DEFAULT 0,
  priority TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Completions with date tracking
CREATE TABLE completions (
  id TEXT PRIMARY KEY,
  habit_id TEXT,
  task_id TEXT,
  completed_at DATETIME NOT NULL,
  completion_date DATE NOT NULL, -- For calendar queries
  notes TEXT,
  FOREIGN KEY (habit_id) REFERENCES habits (id),
  FOREIGN KEY (task_id) REFERENCES tasks (id)
);
```

## 🎨 Calendar UI Components

### 1. Calendar Widget Features
- **Month Navigation**: Smooth swipe between months
- **Visual Indicators**: 
  - Green dots for completed habits
  - Red dots for pending habits
  - Colored squares for tasks (by priority)
  - Fire emojis for streak days
- **Interactive Days**: Tap to view/edit day details
- **Today Highlighting**: Clear visual emphasis on current day

### 2. Calendar Event Colors
- **Habits**: Primary color (#6366F1) variations
- **High Priority Tasks**: Error color (#EF4444)
- **Medium Priority Tasks**: Warning color (#F59E0B)
- **Low Priority Tasks**: Success color (#10B981)
- **Completed Items**: Muted/grayed versions
- **Streaks**: Fire emoji (🔥) with streak count

### 3. Calendar Interactions
- **Tap Day**: Show day detail modal
- **Long Press**: Quick add habit/task
- **Swipe Months**: Navigate between months
- **Pull to Refresh**: Sync calendar data
- **Drag & Drop**: Reschedule tasks (advanced)

## 🚀 Calendar Dependencies

### Updated pubspec.yaml additions:
```yaml
dependencies:
  # Calendar & Date
  table_calendar: ^3.0.9
  timezone: ^0.9.4
  
  # Already included in your pubspec:
  intl: ^0.19.0
```

## 🎯 Calendar-Enhanced Gamification

### 1. Calendar Heat Map
- **GitHub-style**: Visual representation of daily activity
- **Color Intensity**: Darker colors for higher completion rates
- **Streak Tracking**: Continuous color blocks for streaks
- **Monthly View**: See patterns and consistency at a glance

### 2. Calendar-Based Achievements
- **Perfect Week**: Complete all habits for 7 consecutive days
- **Month Master**: 90%+ completion rate for entire month
- **Consistency King**: No missed days for 30 days
- **Weekend Warrior**: Perfect weekend habit completion

### 3. Visual Progress Indicators
- **Completion Circles**: Daily completion percentage
- **Streak Flames**: Fire emoji with day count
- **Progress Bars**: Weekly/monthly progress visualization
- **Achievement Badges**: Unlocked milestones on calendar

## 📋 Updated Development Priorities

### Phase 1: Calendar Foundation
1. Integrate table_calendar widget
2. Create calendar-aware data models
3. Implement date-based habit scheduling
4. Add task due date functionality

### Phase 2: Calendar Views
1. Build month view with indicators
2. Create today view with agenda layout
3. Implement day detail modals
4. Add calendar navigation

### Phase 3: Calendar Features
1. Add calendar heat map for streaks
2. Implement quick actions from calendar
3. Create calendar-based analytics
4. Polish calendar interactions

## 🎉 Calendar MVP Success Metrics

### User Engagement
- [ ] User schedules habits using calendar
- [ ] User sets task due dates via calendar
- [ ] User navigates primarily through calendar view
- [ ] User completes habits/tasks from calendar interface

### Calendar-Specific Goals
- [ ] Calendar loads within 1 second
- [ ] Smooth month navigation (60fps)
- [ ] Accurate visual indicators for all events
- [ ] Intuitive day detail interactions

This enhanced MVP with calendar integration transforms NextTick from a simple habit tracker into a comprehensive productivity companion with visual scheduling, due date management, and calendar-based progress tracking!