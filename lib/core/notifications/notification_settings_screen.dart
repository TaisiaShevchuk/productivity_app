import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'notification_coordinator.dart';
import 'notification_settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationSettings _settings = const NotificationSettings();
  final List<TextEditingController> _reminderControllers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _reminderControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await NotificationSettingsService.load();
    if (!mounted) return;

    for (final controller in _reminderControllers) {
      controller.dispose();
    }
    _reminderControllers
      ..clear()
      ..addAll(
        settings.deadlineReminderHours.map(
          (hours) => TextEditingController(text: '$hours'),
        ),
      );

    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _pickDailyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.dailyHour,
        minute: _settings.dailyMinute,
      ),
    );
    if (picked == null) return;
    setState(() {
      _settings = _settings.copyWith(
        dailyHour: picked.hour,
        dailyMinute: picked.minute,
      );
    });
  }

  void _addReminder() {
    setState(() {
      _reminderControllers.add(TextEditingController(text: '1'));
    });
  }

  void _removeReminder(int index) {
    setState(() {
      _reminderControllers.removeAt(index).dispose();
    });
  }

  Future<void> _save() async {
    final hours = _reminderControllers
        .map((controller) => int.tryParse(controller.text))
        .whereType<int>()
        .where((value) => value > 0)
        .toList();
    final settings = _settings.copyWith(deadlineReminderHours: hours);

    await NotificationSettingsService.save(settings);
    await NotificationCoordinator.rescheduleAll();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.dailyReminder),
                  subtitle: Text(l10n.dailyReminderDescription),
                  value: _settings.dailyEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(dailyEnabled: value);
                    });
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: _settings.dailyEnabled,
                  title: Text(l10n.reminderTime),
                  subtitle: Text(
                    TimeOfDay(
                      hour: _settings.dailyHour,
                      minute: _settings.dailyMinute,
                    ).format(context),
                  ),
                  trailing: const Icon(Icons.schedule),
                  onTap: _settings.dailyEnabled ? _pickDailyTime : null,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.deadlineNotifications),
                  subtitle: Text(l10n.deadlineNotificationsDescription),
                  value: _settings.deadlineEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(deadlineEnabled: value);
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.reminderCount,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text('${_reminderControllers.length}'),
                    IconButton(
                      tooltip: l10n.addReminder,
                      onPressed: _settings.deadlineEnabled
                          ? _addReminder
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                ..._reminderControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            enabled: _settings.deadlineEnabled,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.reminderBeforeDeadline,
                              suffixText: l10n.hours,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.delete,
                          onPressed: _settings.deadlineEnabled
                              ? () => _removeReminder(index)
                              : null,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
