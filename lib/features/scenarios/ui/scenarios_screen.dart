import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/scenario_repository.dart';
import '../data/scenario_service.dart';
import '../models/scenario_template.dart';
import 'scenario_editor_screen.dart';

class ScenariosScreen extends StatefulWidget {
  final Future<void> Function()? onApplied;

  const ScenariosScreen({
    super.key,
    this.onApplied,
  });

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final ScenarioService _service = ScenarioService();
  final ScenarioRepository _repository = ScenarioRepository();

  List<ScenarioTemplate> _customTemplates = [];
  String? _appliedId;

  @override
  void initState() {
    super.initState();
    _loadCustomTemplates();
  }

  Future<void> _loadCustomTemplates() async {
    final templates = await _repository.getCustomScenarios();
    if (!mounted) return;
    setState(() => _customTemplates = templates);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templates = [..._defaultTemplates(l10n), ..._customTemplates];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createCustomScenario,
              icon: const Icon(Icons.add),
              label: Text(l10n.createCustomScenario),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final isCustom = _customTemplates.any(
                (item) => item.id == template.id,
              );

              return _ScenarioCard(
                template: template,
                applied: _appliedId == template.id,
                isCustom: isCustom,
                onApply: () => _editAndApply(template),
                onEdit: () => _editCustomScenario(template),
                onDelete: isCustom ? () => _deleteCustomScenario(template) : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createCustomScenario() async {
    final result = await Navigator.push<ScenarioTemplate>(
      context,
      MaterialPageRoute(builder: (_) => const ScenarioEditorScreen()),
    );

    if (result == null) return;
    await _repository.saveCustomScenario(result);
    await _loadCustomTemplates();
  }

  Future<void> _editCustomScenario(ScenarioTemplate template) async {
    final result = await Navigator.push<ScenarioTemplate>(
      context,
      MaterialPageRoute(
        builder: (_) => ScenarioEditorScreen(template: template),
      ),
    );

    if (result == null) return;
    await _repository.saveCustomScenario(result);
    await _loadCustomTemplates();
  }

  Future<void> _deleteCustomScenario(ScenarioTemplate template) async {
    await _repository.deleteCustomScenario(template.id);
    await _loadCustomTemplates();
  }

  Future<void> _editAndApply(ScenarioTemplate template) async {
    final l10n = AppLocalizations.of(context)!;
    final edited = await Navigator.push<ScenarioTemplate>(
      context,
      MaterialPageRoute(
        builder: (_) => ScenarioEditorScreen(
          template: template,
        ),
      ),
    );

    if (edited == null) return;

    await _service.applyScenario(edited);
    await widget.onApplied?.call();
    if (!mounted) return;
    setState(() => _appliedId = template.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.scenarioApplied)),
    );
  }

  List<ScenarioTemplate> _defaultTemplates(AppLocalizations l10n) {
    return [
      ScenarioTemplate(
        id: 'health',
        name: l10n.scenarioHealthName,
        description: l10n.scenarioHealthDescription,
        goals: [
          GoalTemplate(
            title: l10n.scenarioHealthGoal,
            deadlineDaysFromNow: 60,
            subtasks: [
              l10n.scenarioHealthSubtaskMenu,
              l10n.scenarioHealthSubtaskWorkouts,
              l10n.scenarioHealthSubtaskSleep,
            ],
          ),
        ],
        habits: [
          l10n.scenarioHealthHabitWater,
          l10n.scenarioHealthHabitSteps,
          l10n.scenarioHealthHabitSleep,
        ],
        tasks: [
          l10n.scenarioHealthTaskMenu,
          l10n.scenarioHealthTaskWorkout,
        ],
      ),
      ScenarioTemplate(
        id: 'study',
        name: l10n.scenarioStudyName,
        description: l10n.scenarioStudyDescription,
        goals: [
          GoalTemplate(
            title: l10n.scenarioStudyGoal,
            deadlineDaysFromNow: 45,
            subtasks: [
              l10n.scenarioStudySubtaskPlan,
              l10n.scenarioStudySubtaskSources,
              l10n.scenarioStudySubtaskDraft,
            ],
          ),
        ],
        habits: [
          l10n.scenarioStudyHabitReading,
          l10n.scenarioStudyHabitReview,
        ],
        tasks: [
          l10n.scenarioStudyTaskSchedule,
          l10n.scenarioStudyTaskMaterials,
        ],
      ),
      ScenarioTemplate(
        id: 'budget',
        name: l10n.scenarioBudgetName,
        description: l10n.scenarioBudgetDescription,
        goals: [
          GoalTemplate(
            title: l10n.scenarioBudgetGoal,
            deadlineDaysFromNow: 30,
            subtasks: [
              l10n.scenarioBudgetSubtaskExpenses,
              l10n.scenarioBudgetSubtaskLimit,
              l10n.scenarioBudgetSubtaskSavings,
            ],
          ),
        ],
        habits: [
          l10n.scenarioBudgetHabitExpenses,
          l10n.scenarioBudgetHabitReview,
        ],
        tasks: [
          l10n.scenarioBudgetTaskCategories,
          l10n.scenarioBudgetTaskSubscriptions,
        ],
      ),
    ];
  }
}

class _ScenarioCard extends StatelessWidget {
  final ScenarioTemplate template;
  final bool applied;
  final bool isCustom;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _ScenarioCard({
    required this.template,
    required this.applied,
    required this.isCustom,
    required this.onApply,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  template.name,
                  style: tt.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCustom)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            template.description,
            style: tt.bodyMedium!.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          _PreviewLine(
            icon: Icons.flag,
            label: l10n.goals,
            values: template.goals.map((goal) => goal.title).toList(),
          ),
          _PreviewLine(
            icon: Icons.repeat,
            label: l10n.habits,
            values: template.habits,
          ),
          _PreviewLine(
            icon: Icons.task_alt,
            label: l10n.tasks,
            values: template.tasks,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: applied ? null : onApply,
              icon: Icon(applied ? Icons.check : Icons.tune),
              label: Text(applied ? l10n.scenarioApplied : l10n.editAndApply),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> values;

  const _PreviewLine({
    required this.icon,
    required this.label,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white60),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${values.join(', ')}',
              style: tt.bodySmall!.copyWith(color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
