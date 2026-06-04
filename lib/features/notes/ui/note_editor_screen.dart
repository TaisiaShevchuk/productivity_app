import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../data/notes_repository.dart';
import '../../../data/database_helper.dart';
import '../../trash/ui/confirm_delete.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/note_linked_entities.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late bool isNew;
  Note? currentNote;

  Timer? autosaveTimer;

  @override
  void initState() {
    super.initState();

    isNew = widget.note == null;
    currentNote = widget.note;

    titleController = TextEditingController(text: currentNote?.title ?? "");
    contentController = TextEditingController(text: currentNote?.content ?? "");

    autosaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _autoSave();
    });
  }

  @override
  void dispose() {
    autosaveTimer?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _autoSave() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    final repo = NotesRepository();

    if (isNew) {
      final newNote = Note(
        id: null,
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );

      await repo.insertNote(newNote);

      final notes = await repo.getNotes();
      currentNote = notes.first;

      isNew = false;
      if (mounted) setState(() {});
    } else {
      final updated = Note(
        id: currentNote!.id,
        title: title,
        content: content,
        createdAt: currentNote!.createdAt,
      );

      await repo.updateNote(updated);
      currentNote = updated;
    }
  }

  Future<void> saveNote() async {
    await _autoSave();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> deleteNote() async {
    if (currentNote == null) return;

    final confirm = await showConfirmDelete(context);
    if (!confirm) return;

    await DatabaseHelper.instance.deleteItem(
      "note",
      currentNote!.id!,
      currentNote!.toMap(),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: AppTheme.pageDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(isNew ? l10n.newNote : l10n.editNote, style: tt.titleLarge),
          actions: [
            if (!isNew)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: deleteNote,
              ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: saveNote,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (currentNote?.id != null)
                NoteLinkedEntities(noteId: currentNote!.id!),
              TextField(
                controller: titleController,
                style: tt.titleLarge,
                decoration: InputDecoration(
                  hintText: l10n.title,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: tt.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.writeNote,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
