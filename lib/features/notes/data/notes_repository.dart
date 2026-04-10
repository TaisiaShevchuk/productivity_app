import '../../../data/database_helper.dart';
import '../models/note.dart';

class NotesRepository {
  Future<List<Note>> getNotes() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> insertNote(Note note) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('notes', note.toMap());
  }

  Future<void> updateNote(Note note) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
}
