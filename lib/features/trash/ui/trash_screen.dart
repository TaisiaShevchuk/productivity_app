import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import 'confirm_delete.dart';
import '../../../l10n/app_localizations.dart';

class TrashScreen extends StatefulWidget {
  final Future<void> Function()? onChanged;

  const TrashScreen({super.key, this.onChanged});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Map<String, dynamic>> items = [];
  String filter = "all";
  bool sortDescending = true;
  final Set<int> _busyItems = {};
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  Future<void> _loadTrash() async {
    final data = await DatabaseHelper.instance.getTrash();

    //sort by deletion date
    data.sort((a, b) {
      final da = (a['deleted_at'] as num?)?.toInt() ?? 0;
      final db = (b['deleted_at'] as num?)?.toInt() ?? 0;
      return sortDescending ? db.compareTo(da) : da.compareTo(db);
    });

    if (!mounted) return;
    setState(() => items = data);
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "note":
        return Icons.note;
      case "task":
        return Icons.check_circle_outline;
      case "goal":
        return Icons.flag;
      case "habit":
        return Icons.repeat;
      default:
        return Icons.delete;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final filtered = filter == "all"
        ? items
        : items.where((e) => e['type'] == filter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            onPressed: () {
              setState(() => sortDescending = !sortDescending);
              _loadTrash();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearing || _busyItems.isNotEmpty || items.isEmpty
                ? null
                : () async {
              final confirm = await showConfirmDelete(context);
              if (!confirm) return;

              setState(() => _clearing = true);
              try {
                await DatabaseHelper.instance.clearTrash();
                await _loadTrash();
              } catch (error) {
                _showOperationError(error);
              } finally {
                if (mounted) setState(() => _clearing = false);
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ---------- FILTERS ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("all", l10n.all),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    "note",
                    l10n.note.characters.first.toUpperCase(),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    "task",
                    l10n.task.characters.first.toUpperCase(),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    "goal",
                    l10n.goal.characters.first.toUpperCase(),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    "habit",
                    l10n.habit.characters.first.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),

          // ---------- LIST ----------
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(l10n.noItems, style: tt.bodyLarge))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final itemId = item['id'] as int;
                      final isBusy = _clearing || _busyItems.contains(itemId);
                      final type = item['type']?.toString() ?? 'unknown';
                      final data = _decodeItemData(item['data']);
                      final deletedAt = DateTime.fromMillisecondsSinceEpoch(
                        (item['deleted_at'] as num?)?.toInt() ?? 0,
                      );

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          key: ValueKey(item['id']),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_getIcon(type), size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    type.toUpperCase(),
                                    style: tt.titleMedium,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                (data['title'] ??
                                        data['content'] ??
                                        l10n.noText)
                                    .toString(),
                                style: tt.bodyLarge,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "${l10n.deleted}: ${deletedAt.day.toString().padLeft(2, '0')}"
                                ".${deletedAt.month.toString().padLeft(2, '0')}"
                                ".${deletedAt.year}",
                                style: tt.bodySmall!.copyWith(
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: isBusy
                                        ? null
                                        : () => _restoreItem(itemId),
                                    child: isBusy
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(l10n.restore),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: isBusy ? null : () async {
                                      final confirm = await showConfirmDelete(
                                        context,
                                      );
                                      if (!confirm) return;

                                      await _deletePermanently(itemId);
                                    },
                                    child: Text(
                                      l10n.deleteForever,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- FILTERS ----------
  Widget _buildFilterChip(String value, String label) {
    final selected = filter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) {
        setState(() => filter = value);
      },
    );
  }

  void _removeLocalItem(int id) {
    if (!mounted) return;
    setState(() {
      items.removeWhere((item) => item['id'] == id);
    });
  }

  Future<void> _restoreItem(int id) async {
    setState(() => _busyItems.add(id));
    try {
      await DatabaseHelper.instance.restoreFromTrash(id);
      _removeLocalItem(id);
      await widget.onChanged?.call();
    } catch (error) {
      await _loadTrash();
      _showOperationError(error);
    } finally {
      if (mounted) setState(() => _busyItems.remove(id));
    }
  }

  Future<void> _deletePermanently(int id) async {
    setState(() => _busyItems.add(id));
    try {
      await DatabaseHelper.instance.deleteFromTrash(id);
      _removeLocalItem(id);
    } catch (error) {
      await _loadTrash();
      _showOperationError(error);
    } finally {
      if (mounted) setState(() => _busyItems.remove(id));
    }
  }

  void _showOperationError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trash operation failed: $error')),
    );
  }

  Map<String, dynamic> _decodeItemData(Object? raw) {
    try {
      final decoded = jsonDecode(raw?.toString() ?? '');
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
