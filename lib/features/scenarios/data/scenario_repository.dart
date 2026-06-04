import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scenario_template.dart';

class ScenarioRepository {
  static const _key = 'custom_scenarios';

  Future<List<ScenarioTemplate>> getCustomScenarios() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => ScenarioTemplate.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<void> saveCustomScenario(ScenarioTemplate template) async {
    final scenarios = await getCustomScenarios();
    final index = scenarios.indexWhere((item) => item.id == template.id);

    if (index == -1) {
      scenarios.add(template);
    } else {
      scenarios[index] = template;
    }

    await _saveAll(scenarios);
  }

  Future<void> deleteCustomScenario(String id) async {
    final scenarios = await getCustomScenarios();
    scenarios.removeWhere((item) => item.id == id);
    await _saveAll(scenarios);
  }

  Future<void> _saveAll(List<ScenarioTemplate> scenarios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(scenarios.map((item) => item.toJson()).toList()),
    );
  }
}
