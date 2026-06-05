import 'package:flutter/material.dart';
import '../app/app_navigation_rail.dart';
import '../data/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../core/widgets/linked_note_field.dart';
import '../core/theme/app_theme.dart';

// NOTES
import '../features/notes/data/notes_repository.dart';
import '../features/notes/models/note.dart';
import '../features/notes/ui/widgets/note_card.dart';
import '../features/notes/ui/note_editor_screen.dart';

// TASKS
import '../features/tasks/data/tasks_repository.dart';
import '../features/tasks/models/task.dart';
import '../features/tasks/ui/add_task_screen.dart';
import '../features/tasks/ui/edit_task_screen.dart';

// HABITS
import '../features/habits/models/habit.dart';
import '../features/habits/ui/habits_screen.dart';

// GOALS
import '../features/goals/ui/goals_screen.dart';

// SCENARIOS
import '../features/scenarios/ui/scenarios_screen.dart';

// ASSISTANT
import '../features/assistant/ui/assistant_screen.dart';

// STATS
import '../features/stats/stats_screen.dart';

// CALENDAR
import '../features/calendar/ui/calendar_screen.dart';

// SETTINGS
import '../core/widgets/settings_popup.dart';

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
  bool _navigationVisible = true;

  List<Task> tasks = [];
  List<Note> notes = [];
  List<Habit> habits = [];

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

  Future<void> _refreshHomeData() async {
    await Future.wait([_loadTasks(), _loadNotes(), _loadHabits()]);
  }

  void _showSettingsPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsPopup(),
    );
  }

  Widget? _buildFAB() {
    if (selectedIndex == 0 ||
        selectedIndex == 2 ||
        selectedIndex == 3 ||
        selectedIndex == 6 ||
        selectedIndex == 7 ||
        selectedIndex == 8 ||
        selectedIndex == 9) {
      return null;
    }

    //NOTES
    if (selectedIndex == 4) {
      return FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add),
      );
    }

    //TASKS
    if (selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (result == true) _loadTasks();
        },
        child: const Icon(Icons.add),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context)!;
    final titles = _localizedTitles(l10n);

    return Container(
      decoration: AppTheme.pageDecoration(context),
      child: Stack(
        children: [
          Row(
            children: [
              //NavigationRail
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _navigationVisible
                    ? AnimatedContainer(
                        key: const ValueKey('navigation-rail'),
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          top: topPadding + 52,
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
                              if (index == 6) {
                                setState(() => selectedIndex = index);
                              } else if (index == 8) {
                                _showSettingsPopup();
                              } else {
                                setState(() => selectedIndex = index);
                                if (index == 4) _loadNotes();
                                if (index == 2) _loadHabits();
                              }
                            },
                            habits: habits,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('navigation-hidden')),
              ),

              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBody: true,
                  extendBodyBehindAppBar: false,

                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    titleSpacing: _navigationVisible ? null : 72,
                    title: Text(titles[selectedIndex], style: tt.titleLarge),
                  ),

                  body: _buildBody(),
                  floatingActionButton: _buildFAB(),
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            top: topPadding + 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() => _navigationVisible = !_navigationVisible);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    _navigationVisible ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _localizedTitles(AppLocalizations l10n) => [
    l10n.calendar,
    l10n.task,
    l10n.habits,
    l10n.goals,
    l10n.notes,
    l10n.scenarios,
    l10n.assistant,
    l10n.stats,
    l10n.settings,
    l10n.trash,
  ];

  Widget _buildBody() {
    final titles = _localizedTitles(AppLocalizations.of(context)!);
    if (selectedIndex == 0) return const CalendarScreen();
    if (selectedIndex == 1) return _buildTaskList();
    if (selectedIndex == 2) return const HabitsScreen();
    if (selectedIndex == 3) return const GoalsScreen();
    if (selectedIndex == 4) return _buildNotesScreen();
    if (selectedIndex == 5) {
      return ScenariosScreen(onApplied: _refreshHomeData);
    }
    if (selectedIndex == 6) return const AssistantScreen();
    if (selectedIndex == 7) return StatisticsScreen(habits: habits);
    if (selectedIndex == 9) return const TrashScreen();

    return Center(
      child: Text(
        titles[selectedIndex],
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildNotesScreen() {
    final tt = Theme.of(context).textTheme;

    return notes.isEmpty
        ? Center(
            child: Text(
              AppLocalizations.of(context)!.noNotes,
              style: tt.bodyLarge,
            ),
          )
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
        ? Center(
            child: Text(
              AppLocalizations.of(context)!.noTasks,
              style: tt.bodyLarge,
            ),
          )
        : ListView.builder(
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];

              return ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    await TasksRepository().toggleTask(task.id!, !task.isDone);
                    _loadTasks();
                  },
                  child: Icon(
                    task.isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: task.isDone ? Colors.green : cs.secondary,
                    size: 28,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: tt.bodyLarge!.copyWith(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone
                            ? Colors.white.withOpacity(0.5)
                            : tt.bodyLarge!.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.deadline != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTaskDeadlineDate(task.deadline!),
                            maxLines: 1,
                            softWrap: false,
                            style: tt.bodySmall!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _formatTaskDeadlineTime(task.deadline!),
                            maxLines: 1,
                            softWrap: false,
                            style: tt.bodySmall!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinkedNoteIconButton(noteId: task.noteId),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: task),
                          ),
                        );
                        if (result == true) _loadTasks();
                      },
                    ),
                    IconButton(
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
                  ],
                ),
              );
            },
          );
  }

  String _formatTaskDeadlineDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}';
  }

  String _formatTaskDeadlineTime(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
