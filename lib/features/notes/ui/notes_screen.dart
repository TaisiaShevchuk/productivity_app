import 'package:flutter/material.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';
import 'widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final repo = NotesRepository();
    notes = await repo.getNotes();
    setState(() => loading = false);
  }

  Future<void> _openEditor([Note? note]) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (updated == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E385A),
            Color(0xFF6C5E82),
            Color(0xFFA091A7),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(),
          child: const Icon(Icons.add),
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : notes.isEmpty
            ? Center(
          child: Text(
            "No notes yet",
            style: tt.titleLarge!.copyWith(color: Colors.white70),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];

            return NoteCard(
              title: note.title,
              onTap: () => _openEditor(note),
            );
          },
        ),
      ),
    );
  }
}
