# Productivity App

A local-first productivity application built with Flutter. It brings tasks,
goals, habits, notes, calendar planning, statistics, reusable scenarios, and
personal recommendations into a single workspace.

The application stores user data locally and can be used without an internet
connection.

## Features

### Tasks

- Create, edit, complete, reopen, and delete tasks.
- Add an optional deadline with a date and time.
- Display task deadlines in the calendar.
- Link an existing or newly created note to a task.
- Open a linked note directly from the task list.

### Goals

- Create and edit goals with optional deadlines.
- Split goals into editable subtasks.
- Track completion automatically from finished subtasks.
- View progress as a percentage and a circular indicator.
- Link goals to notes.

### Habits

- Create, edit, reorder, and delete habits.
- Mark completion for each day of the week.
- View weekly completion progress and current streaks.
- Link habits to notes.
- Automatically reset weekly tracking data.

### Notes

- Create, edit, and delete text notes.
- Automatically save notes every 10 seconds.
- Link notes to tasks, goals, and habits.
- Navigate from a note back to all linked items.

### Calendar

- View two independently navigable monthly calendars.
- Highlight days containing task or goal deadlines.
- View deadlines and their times for a selected day.
- Open tasks and goals directly from the calendar.

### Scenarios

- Apply built-in planning scenarios for health, study, and budgeting.
- Review and edit a scenario before applying it.
- Create, edit, and delete an unlimited number of custom scenarios.
- Generate multiple tasks, goals, and habits from one scenario.

### Productivity Assistant

- Show the number of incomplete tasks.
- Identify the nearest active goal deadline.
- Highlight the habit with the lowest weekly completion.
- Provide a simple productivity forecast and recommendations.

### Statistics

- View weekly habit completion and streaks.
- View completed and incomplete task totals.
- View completed and incomplete goal totals.
- Review unfinished tasks, their deadlines, and goal progress.

### Notifications

- Configure a daily reminder to open the application.
- Change the daily reminder time or disable it.
- Enable or disable deadline notifications.
- Create any number of deadline reminders.
- Configure how many hours before a deadline each reminder should appear.
- Automatically reschedule notifications after deadline changes.

### Trash

- Move deleted tasks, goals, habits, and notes to the trash.
- Filter and sort deleted items.
- Restore items from the trash.
- Permanently delete individual items or clear the entire trash.

### Personalization

- Switch between English, Russian, and Finnish.
- Choose a dark, light, or monochrome theme.
- Preserve language, theme, and notification settings between launches.

## Technology Stack

- Flutter and Dart
- Material Design
- SQLite with `sqflite`
- Shared preferences
- Flutter local notifications
- Timezone-aware notification scheduling
- Flutter internationalization

## Project Structure

```text
lib/
|-- app/                 # Application shell and navigation
|-- core/
|   |-- notifications/   # Notification scheduling and settings
|   |-- theme/           # Application themes
|   |-- utils/           # Shared services
|   `-- widgets/         # Reusable widgets
|-- data/                # Local SQLite database access
|-- features/
|   |-- assistant/
|   |-- calendar/
|   |-- goals/
|   |-- habits/
|   |-- notes/
|   |-- scenarios/
|   |-- stats/
|   |-- tasks/
|   `-- trash/
|-- l10n/                # Localization resources
`-- main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK with Dart `3.11.3` or newer
- Android Studio or another Flutter-compatible IDE
- An Android emulator or physical Android device

### Installation

```bash
git clone https://github.com/TaisiaShevchuk/productivity_app.git
cd productivity_app
flutter pub get
flutter gen-l10n
```

### Run the Application

```bash
flutter run
```

### Build an Android APK

```bash
flutter build apk
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Local Data and Permissions

Application data is stored locally in an SQLite database. Preferences such as
the selected language, theme, and notification schedule are stored using shared
preferences.

On Android, the application requests notification and exact alarm permissions
to schedule daily and deadline reminders. Available notification behavior may
depend on the device and Android version.

## Development Checks

```bash
flutter analyze
flutter test
```

## Author

Taisiia Shevchuk

Information Technology student, Vaasa, Finland
