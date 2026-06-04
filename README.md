Productivity App
A modern, modular productivity application built with Flutter.
It unifies tasks, goals, habits, notes, and a calendar into one clean and efficient workspace.
Designed for convenient distribution of tasks.

Features:
Calendar
Monthly calendar view
Smooth month navigation
Goal indicators on specific days
Tap any day to view goals in a popup
Load goals for a specific date
Load all goals for the month

Tasks
View all tasks
Automatic sorting (incomplete → complete)
Add new tasks
Edit existing tasks
Mark tasks as done/undone
Delete tasks (sent to Trash)
Persistent storage via SQLite

Notes
View all notes
Open and edit notes
Auto‑refresh after editing
Persistent storage
Delete notes (sent to Trash)

Habits
View all habits
Load habits from database
Display habits inside NavigationRail
Persistent storage

Goals
View all goals
Load all goals from database
Load goals for a specific date
Integrated with the calendar
Persistent storage

Trash System (In development)
Centralized deletion logic
Universal deleteItem(type, id, map) method
Confirmation dialog before deletion
Trash screen for removed items
(Optional) Restore functionality

Settings
Settings popup
Language selection
Locale saved and loaded on app startup

UI & Design
Gradient background
Transparent AppBar and Scaffold
Animated NavigationRail
Minimalistic, clean UI
Custom calendar cells
Custom note cards
Smooth transitions

Architecture:
The project follows a modular, scalable structure:
Code
lib/
 ├── app/
 │    └── app_navigation_rail.dart
 ├── core/
 │    └── widgets/
 ├── data/
 │    └── database_helper.dart
 ├── features/
 │    ├── calendar/
 │    ├── tasks/
 │    ├── notes/
 │    ├── habits/
 │    ├── goals/
 │    └── trash/
 └── main.dart

Key principles
Clear separation of data / models / ui
Repository pattern for each feature
Centralized database access
Reusable widgets
Maintainable and scalable codebase

Technologies Used
Flutter
Dart
SQLite
Material Design
Android Studio

Getting Started
Install dependencies:
bash
flutter pub get

Run the app:
bash
flutter run

Roadmap
Planned improvements:
Advanced statistics and analytics
Progress charts
Push notifications
Home screen widgets
Cloud sync
Improved habit tracking
Goal progress visualization

Author:
Taisiia Shevchuk
Information Technology student 
Vaasa, Finland

