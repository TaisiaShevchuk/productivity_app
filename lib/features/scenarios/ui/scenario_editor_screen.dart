import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/scenario_template.dart';

class ScenarioEditorScreen extends StatefulWidget {
  final ScenarioTemplate? template;

  const ScenarioEditorScreen({
    super.key,
    this.template,
  });

  @override
  State<ScenarioEditorScreen> createState() => _ScenarioEditorScreenState();
}

class _ScenarioEditorScreenState extends State<ScenarioEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _goalsController;
  late final TextEditingController _habitsController;
  late final TextEditingController _tasksController;

  @override
  void initState() {
    super.initState();
    final template = widget.template;

    _nameController = TextEditingController(text: template?.name ?? '');
    _descriptionController =
        TextEditingController(text: template?.description ?? '');
    _goalsController = TextEditingController(
      text: template?.goals.map((goal) => goal.title).join('\n') ?? '',
    );
    _habitsController = TextEditingController(
      text: template?.habits.join('\n') ?? '',
    );
    _tasksController = TextEditingController(
      text: template?.tasks.join('\n') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalsController.dispose();
    _habitsController.dispose();
    _tasksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null
            ? l10n.customScenario
            : l10n.editScenario),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.scenarioName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.scenarioDescription,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          _MultilineSection(
            title: l10n.goals,
            helper: l10n.scenarioEditorHelper,
            controller: _goalsController,
          ),
          const SizedBox(height: 12),
          _MultilineSection(
            title: l10n.habits,
            helper: l10n.scenarioEditorHelper,
            controller: _habitsController,
          ),
          const SizedBox(height: 12),
          _MultilineSection(
            title: l10n.tasks,
            helper: l10n.scenarioEditorHelper,
            controller: _tasksController,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.scenarioEditorNote,
            style: tt.bodySmall!.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();

    if (name.isEmpty) return;

    final goalTitles = _lines(_goalsController.text);
    final sourceGoals = widget.template?.goals ?? const <GoalTemplate>[];
    final goals = List.generate(goalTitles.length, (index) {
      final source = index < sourceGoals.length ? sourceGoals[index] : null;
      return GoalTemplate(
        title: goalTitles[index],
        deadlineDaysFromNow: source?.deadlineDaysFromNow ?? 30,
        subtasks: source?.subtasks ?? [goalTitles[index]],
      );
    });

    final template = ScenarioTemplate(
      id: widget.template?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? l10n.customScenario
          : _descriptionController.text.trim(),
      goals: goals,
      habits: _lines(_habitsController.text),
      tasks: _lines(_tasksController.text),
    );

    Navigator.pop(context, template);
  }

  List<String> _lines(String value) {
    return value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

class _MultilineSection extends StatelessWidget {
  final String title;
  final String helper;
  final TextEditingController controller;

  const _MultilineSection({
    required this.title,
    required this.helper,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: title,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
