import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import 'confirm_delete.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Map<String, dynamic>> items = [];
  String filter = "all";
  bool sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  Future<void> _loadTrash() async {
    final data = await DatabaseHelper.instance.getTrash();

    //sort by deletion date
    data.sort((a, b) {
      final da = a['deleted_at'];
      final db = b['deleted_at'];
      return sortDescending ? db.compareTo(da) : da.compareTo(db);
    });

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

    final filtered = filter == "all"
        ? items
        : items.where((e) => e['type'] == filter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() => sortDescending = !sortDescending);
              _loadTrash();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirm = await showConfirmDelete(context);
              if (!confirm) return;

              await DatabaseHelper.instance.clearTrash();
              _loadTrash();
            },
          ),
        ],
      ),


      body: Column(
        children: [
          // ---------- FILTERS ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip("all", "All"),
                _buildFilterChip("note", "N"),
                _buildFilterChip("task", "T"),
                _buildFilterChip("goal", "G"),
                _buildFilterChip("habit", "H"),
              ],
            ),
          ),


          // ---------- LIST ----------
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text("No items", style: tt.bodyLarge))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final type = item['type'];
                final data = jsonDecode(item['data']);
                final deletedAt = DateTime.fromMillisecondsSinceEpoch(
                  item['deleted_at'],
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getIcon(type), size: 28),
                            const SizedBox(width: 12),
                            Text(type.toUpperCase(), style: tt.titleMedium),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          data['title'] ?? data['content'] ?? "(no text)",
                          style: tt.bodyLarge,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Deleted: ${deletedAt.day.toString().padLeft(2, '0')}"
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
                              onPressed: () async {
                                await DatabaseHelper.instance
                                    .restoreFromTrash(item);

                                setState(() {
                                  items.removeAt(index);
                                });
                              },
                              child: const Text("Restore"),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () async {
                                final confirm =
                                await showConfirmDelete(context);
                                if (!confirm) return;

                                await DatabaseHelper.instance
                                    .deleteFromTrash(item['id']);

                                setState(() {
                                  items.removeAt(index);
                                });
                              },
                              child: const Text(
                                "Delete forever",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        )
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
}
