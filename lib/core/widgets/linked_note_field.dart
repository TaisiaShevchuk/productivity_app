import 'package:flutter/material.dart';

import '../../data/database_helper.dart';
import '../../features/notes/models/note.dart';
import '../../features/notes/ui/note_editor_screen.dart';
import '../../l10n/app_localizations.dart';

class LinkedNoteField extends StatefulWidget {
  final int? noteId;
  final ValueChanged<int?> onChanged;

  const LinkedNoteField({
    super.key,
    required this.noteId,
    required this.onChanged,
  });

  @override
  State<LinkedNoteField> createState() => _LinkedNoteFieldState();
}

class _LinkedNoteFieldState extends State<LinkedNoteField> {
  Note? _note;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void didUpdateWidget(covariant LinkedNoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteId != widget.noteId) _loadNote();
  }

  Future<void> _loadNote() async {
    final id = widget.noteId;
    if (id == null) {
      if (mounted) setState(() => _note = null);
      return;
    }

    final note = await DatabaseHelper.instance.getNote(id);
    if (mounted) setState(() => _note = note);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.note_alt_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _note?.title.isNotEmpty == true ? _note!.title : l10n.linkNote,
              style: tt.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_note != null)
            IconButton(
              tooltip: l10n.openNote,
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openNote(_note!),
            ),
          IconButton(
            tooltip: l10n.chooseNote,
            icon: const Icon(Icons.link),
            onPressed: _chooseNote,
          ),
          IconButton(
            tooltip: l10n.createLinkedNote,
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _createNote,
          ),
          if (_note != null)
            IconButton(
              tooltip: l10n.removeNoteLink,
              icon: const Icon(Icons.link_off),
              onPressed: () => widget.onChanged(null),
            ),
        ],
      ),
    );
  }

  Future<void> _chooseNote() async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await DatabaseHelper.instance.getNotes();
    if (!mounted) return;

    final selected = await showDialog<Note>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseNote),
        content: SizedBox(
          width: 420,
          child: notes.isEmpty
              ? Text(l10n.noNotes)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      leading: const Icon(Icons.note_alt_outlined),
                      title: Text(
                        note.title.isEmpty ? l10n.noTitle : note.title,
                      ),
                      onTap: () => Navigator.pop(context, note),
                    );
                  },
                ),
        ),
      ),
    );

    if (selected != null) widget.onChanged(selected.id);
  }

  Future<void> _createNote() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final note = await showDialog<Note>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createLinkedNote),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: l10n.title),
              ),
              TextField(
                controller: contentController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(labelText: l10n.writeNote),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                Note(
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  createdAt: DateTime.now(),
                ),
              );
            },
            child: Text(l10n.createAndLink),
          ),
        ],
      ),
    );

    if (note == null) return;
    final id = await DatabaseHelper.instance.insertNote(note);
    widget.onChanged(id);
  }

  Future<void> _openNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    await _loadNote();
  }
}

class LinkedNoteIconButton extends StatelessWidget {
  final int? noteId;

  const LinkedNoteIconButton({
    super.key,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    if (noteId == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: AppLocalizations.of(context)!.openNote,
      icon: const Icon(Icons.note_alt_outlined),
      onPressed: () async {
        final note = await DatabaseHelper.instance.getNote(noteId!);
        if (note == null || !context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
        );
      },
    );
  }
}
