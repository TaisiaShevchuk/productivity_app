import 'package:flutter/material.dart';

import '../app/app_navigation_rail.dart';
import '../data/database_helper.dart';

// NOTES
import '../features/notes/data/notes_repository.dart';
import '../features/notes/models/note.dart';
import '../features/notes/ui/widgets/note_card.dart';
import '../features/notes/ui/note_editor_screen.dart';

// TASKS
import '../features/tasks/data/tasks_repository.dart';
import '../features/tasks/models/task.dart';
import '../features/tasks/ui/add_task_screen.dart';

// HABITS
import '../features/habits/models/habit.dart';
import '../features/habits/ui/habits_screen.dart';

// GOALS
import '../features/goals/ui/goals_screen.dart';

//CALENDAR
import '../features/calendar/ui/calendar_screen.dart';

// SETTINGS
import '../features/settings/ui/settings_popup.dart';

// TRASH
import '../features/trash/ui/trash_screen.dart';
import '../features/trash/ui/confirm_delete.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  List<Task> tasks = [];
  List<Note> notes = [];
  List<Habit> habits = [];

  final List<String> titles = [
    "Notes",
    "Task",
    "Habits",
    "Goals",
    "Calendar",
    "Settings",
    "Trash",
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadNotes();
    _loadHabits();
  }

  Future<void> _loadTasks() async {
    tasks = await TasksRepository().getTasks();
    setState(() {});
  }

  Future<void> _loadNotes() async {
    notes = await NotesRepository().getNotes();
    setState(() {});
  }

  Future<void> _loadHabits() async {
    habits = await DatabaseHelper.instance.getHabits();
    setState(() {});
  }

  void _showSettingsPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E385A),
            Color(0xFF6C5E82),
            Color(0xFFA091A7),
          ],
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12,
              top: topPadding + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AppNavigationRail(
                selectedIndex: selectedIndex,
                onSelect: (index) {
                  if (index == 5) {
                    _showSettingsPopup();
                    return;
                  }
                  setState(() => selectedIndex = index);
                },
                habits: habits,
              ),
            ),
          ),

          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  titles[selectedIndex],
                  style: tt.titleLarge,
                ),
              ),
              body: _buildBody(),
              floatingActionButton: _buildFAB(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (selectedIndex == 0) return _buildNotesScreen();
    if (selectedIndex == 1) return _buildTaskList();
    if (selectedIndex == 2) return const HabitsScreen();
    if (selectedIndex == 3) return const GoalsScreen();
    if (selectedIndex == 4) return const CalendarScreen();
    if (selectedIndex == 6) return const TrashScreen();

    return Center(
      child: Text(
        titles[selectedIndex],
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget? _buildFAB() {
    if (selectedIndex == 0 || selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => selectedIndex == 0
                  ? const NoteEditorScreen()
                  : const AddTaskScreen(),
            ),
          );

          if (result == true) {
            selectedIndex == 0 ? _loadNotes() : _loadTasks();
          }
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Widget _buildNotesScreen() {
    final tt = Theme.of(context).textTheme;

    return notes.isEmpty
        ? Center(child: Text("No notes yet", style: tt.bodyLarge))
        : ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        return NoteCard(
          title: note.title,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(note: note),
              ),
            );
            _loadNotes();
          },
        );
      },
    );
  }

  Widget _buildTaskList() {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final sortedTasks = [...tasks]
      ..sort((a, b) => a.isDone == b.isDone ? 0 : (a.isDone ? 1 : -1));

    return sortedTasks.isEmpty
        ? Center(child: Text('No tasks yet', style: tt.bodyLarge))
        : ListView.builder(
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];

        return ListTile(
          leading: GestureDetector(
            onTap: () async {
              await TasksRepository()
                  .toggleTask(task.id!, !task.isDone);
              _loadTasks();
            },
            child: Icon(
              task.isDone
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: task.isDone ? Colors.green : cs.secondary,
              size: 28,
            ),
          ),

          title: Text(
            task.title,
            style: tt.bodyLarge!.copyWith(
              decoration:
              task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone
                  ? Colors.white.withOpacity(0.5)
                  : tt.bodyLarge!.color,
            ),
          ),

          trailing: IconButton(
            icon: Icon(Icons.delete, color: cs.secondary),
            onPressed: () async {
              final confirm = await showConfirmDelete(context);
              if (!confirm) return;

              await DatabaseHelper.instance.deleteItem(
                "task",
                task.id!,
                task.toMap(),
              );

              _loadTasks();
            },
          ),
        );
      },
    );
  }
}
