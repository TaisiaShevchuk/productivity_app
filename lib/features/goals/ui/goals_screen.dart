import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import 'add_goal_screen.dart';
import 'edit_goal_screen.dart';
import '../../trash/ui/confirm_delete.dart';
import '../../../l10n/app_localizations.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final data = await DatabaseHelper.instance.getGoals();
    setState(() => goals = data);
  }

  Future<void> _openAddGoal() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGoalScreen()),
    );

    if (updated == true) {
      _loadGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGoal,
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? Center(child: Text(l10n.noGoals, style: tt.bodyLarge))
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: goals.length,
        itemBuilder: (_, i) {
          final goal = goals[i];

          return GoalCard(
            goal: goal,
            onDelete: () async {
              final confirm = await showConfirmDelete(context);
              if (!confirm) return;

              await DatabaseHelper.instance.deleteItem(
                "goal",
                goal.id!,
                goal.toMap(),
              );

              _loadGoals();
            },
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditGoalScreen(goal: goal),
                ),
              );

              if (updated == true) {
                _loadGoals();
              }
            },
          );
        },
      ),
    );
  }
}
