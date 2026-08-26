import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../features/notes/models/note.dart';
import '../features/tasks/models/task.dart';
import '../features/habits/models/habit.dart';
import '../features/goals/models/goal.dart';
import '../core/notifications/notification_service.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  //INIT
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 10,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _ensureDB,
    );
  }

  //CREATE TABLES
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        deadline INTEGER,
        noteId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        days TEXT NOT NULL,
        lastReset INTEGER NOT NULL,
        noteId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        progress INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        deadline INTEGER,
        noteId INTEGER,
        subtasks TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE trash (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        deleted_at INTEGER NOT NULL
      )
    ''');
  }

  //MIGRATIONS
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasDeadline = columns.any((column) => column['name'] == 'deadline');

      if (!hasDeadline) {
        await db.execute('ALTER TABLE tasks ADD COLUMN deadline INTEGER');
      }
    }

    if (oldVersion < 9) {
      await _addColumnIfMissing(db, 'tasks', 'noteId', 'INTEGER');
      await _addColumnIfMissing(db, 'habits', 'noteId', 'INTEGER');
      await _addColumnIfMissing(db, 'goals', 'noteId', 'INTEGER');
    }

    if (oldVersion < 10) {
      await _ensureDB(db);
    }
  }

  Future<void> _ensureDB(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trash (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        deleted_at INTEGER NOT NULL
      )
    ''');

    await _addColumnIfMissing(db, 'tasks', 'deadline', 'INTEGER');
    await _addColumnIfMissing(db, 'tasks', 'noteId', 'INTEGER');
    await _addColumnIfMissing(db, 'habits', 'noteId', 'INTEGER');
    await _addColumnIfMissing(db, 'goals', 'noteId', 'INTEGER');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    if (!columns.any((item) => item['name'] == column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  //UNIVERSAL DELETE
  Future<void> deleteItem(
    String type,
    int id,
    Map<String, dynamic> _,
  ) async {
    final db = await database;
    final table = _tableForTrashType(type);

    await db.transaction((txn) async {
      final rows = await txn.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      // A second tap must not create another trash entry for an item that
      // has already been deleted.
      if (rows.isEmpty) return;

      final cleanData = Map<String, dynamic>.from(rows.first);

      if (type == 'note') {
        cleanData['_linkedTaskIds'] = await _linkedIds(
          txn,
          'tasks',
          id,
        );
        cleanData['_linkedGoalIds'] = await _linkedIds(
          txn,
          'goals',
          id,
        );
        cleanData['_linkedHabitIds'] = await _linkedIds(
          txn,
          'habits',
          id,
        );
      }

      await txn.insert('trash', {
        'type': type,
        'data': jsonEncode(cleanData),
        'deleted_at': DateTime.now().millisecondsSinceEpoch,
      });

      if (type == 'note') {
        await txn.update(
          'tasks',
          {'noteId': null},
          where: 'noteId = ?',
          whereArgs: [id],
        );
        await txn.update(
          'goals',
          {'noteId': null},
          where: 'noteId = ?',
          whereArgs: [id],
        );
        await txn.update(
          'habits',
          {'noteId': null},
          where: 'noteId = ?',
          whereArgs: [id],
        );
      }

      await txn.delete(table, where: 'id = ?', whereArgs: [id]);
    });

    try {
      if (type == 'task') await NotificationService.instance.cancelTask(id);
      if (type == 'goal') await NotificationService.instance.cancelGoal(id);
    } catch (_) {
      // The database deletion has succeeded already. A platform notification
      // failure must not make the trash operation appear to have failed.
    }
  }

  //TRASH
  Future<List<Map<String, dynamic>>> getTrash() async {
    final db = await database;
    return await db.query('trash', orderBy: 'deleted_at DESC');
  }

  Future<int> deleteFromTrash(int id) async {
    final db = await database;
    return await db.delete('trash', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearTrash() async {
    final db = await database;
    await db.delete('trash');
  }

  Future<void> restoreFromTrash(int trashId) async {
    final db = await database;

    final restored = await db.transaction<Map<String, dynamic>>((txn) async {
      final rows = await txn.query(
        'trash',
        where: 'id = ?',
        whereArgs: [trashId],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw StateError('The trash item no longer exists.');
      }

      final trashItem = rows.first;
      final type = trashItem['type'] as String;
      final table = _tableForTrashType(type);
      final decoded = jsonDecode(trashItem['data'] as String);

      if (decoded is! Map) {
        throw const FormatException('Invalid trash item data.');
      }

      final storedData = Map<String, dynamic>.from(decoded);
      var record = Map<String, dynamic>.from(storedData)
        ..removeWhere((key, _) => key.startsWith('_'));
      final originalId = record['id'] as int?;

      // Older duplicate trash entries can refer to an object that has
      // already been restored. Treat that operation as completed instead of
      // inserting a duplicate or throwing a primary-key error.
      final existing = originalId == null
          ? <Map<String, Object?>>[]
          : await txn.query(
              table,
              where: 'id = ?',
              whereArgs: [originalId],
              limit: 1,
            );

      if (existing.isEmpty) {
        final restoredId = await txn.insert(table, record);
        record['id'] = originalId ?? restoredId;
      } else if (_sameRecord(record, existing.first)) {
        // This is a duplicate legacy trash entry for an item that has
        // already been restored.
        record = Map<String, dynamic>.from(existing.first);
      } else {
        // Preserve both objects if an unrelated row now uses the old ID.
        record.remove('id');
        record['id'] = await txn.insert(table, record);
      }

      if (type == 'note' && record['id'] != null) {
        await _restoreNoteLinks(txn, record['id'] as int, storedData);
      }

      await txn.delete('trash', where: 'id = ?', whereArgs: [trashId]);

      return {'type': type, 'data': record};
    });

    // Notification scheduling is intentionally performed after the database
    // transaction so notification plugins never leave it half-completed.
    final type = restored['type'] as String;
    final data = restored['data'] as Map<String, dynamic>;
    try {
      if (type == 'task') {
        await NotificationService.instance.scheduleTask(Task.fromMap(data));
      } else if (type == 'goal') {
        await NotificationService.instance.scheduleGoal(Goal.fromMap(data));
      }
    } catch (_) {
      // Restored data remains valid even when notifications are unavailable.
    }
  }

  String _tableForTrashType(String type) {
    switch (type) {
      case 'note':
        return 'notes';
      case 'task':
        return 'tasks';
      case 'habit':
        return 'habits';
      case 'goal':
        return 'goals';
      default:
        throw ArgumentError.value(type, 'type', 'Unsupported trash item type');
    }
  }

  bool _sameRecord(
    Map<String, dynamic> stored,
    Map<String, Object?> existing,
  ) {
    return stored.entries.every((entry) => existing[entry.key] == entry.value);
  }

  Future<List<int>> _linkedIds(
    Transaction txn,
    String table,
    int noteId,
  ) async {
    final rows = await txn.query(
      table,
      columns: ['id'],
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    return rows.map((row) => row['id'] as int).toList();
  }

  Future<void> _restoreNoteLinks(
    Transaction txn,
    int noteId,
    Map<String, dynamic> storedData,
  ) async {
    final links = <String, String>{
      '_linkedTaskIds': 'tasks',
      '_linkedGoalIds': 'goals',
      '_linkedHabitIds': 'habits',
    };

    for (final entry in links.entries) {
      final ids = (storedData[entry.key] as List?)?.whereType<int>() ??
          const Iterable<int>.empty();
      for (final id in ids) {
        await txn.update(
          entry.value,
          {'noteId': noteId},
          where: 'id = ? AND noteId IS NULL',
          whereArgs: [id],
        );
      }
    }
  }

  //NOTES
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<Note?> getNote(int id) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : Note.fromMap(result.first);
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  //TASKS
  Future<int> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    await NotificationService.instance.scheduleTask(
      Task(
        id: id,
        title: task.title,
        isDone: task.isDone,
        deadline: task.deadline,
        noteId: task.noteId,
      ),
    );
    return id;
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    final result = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await NotificationService.instance.scheduleTask(task);
    return result;
  }

  //HABITS
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final result = await db.query('habits');

    final habits = result.map((e) => Habit.fromMap(e)).toList();

    //Automatic weekly reset
    final now = DateTime.now();
    final mondayResetTime = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - DateTime.monday),
      3,
    );

    for (final habit in habits) {
      final lastReset = DateTime.fromMillisecondsSinceEpoch(habit.lastReset);

      if (lastReset.isBefore(mondayResetTime)) {
        habit.days = [0, 0, 0, 0, 0, 0, 0];
        habit.lastReset = now.millisecondsSinceEpoch;
        await updateHabit(habit);
      }
    }

    return habits;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  //GOALS
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    final id = await db.insert('goals', goal.toMap());
    await NotificationService.instance.scheduleGoal(
      Goal(
        id: id,
        title: goal.title,
        isDone: goal.isDone,
        progress: goal.progress,
        createdAt: goal.createdAt,
        deadline: goal.deadline,
        noteId: goal.noteId,
        subtasks: goal.subtasks,
      ),
    );
    return id;
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final result = await db.query('goals');

    final goals = result.map((e) => Goal.fromMap(e)).toList();

    //Automatic progress recalculation
    for (final g in goals) {
      final newProgress = g.calculateProgress();

      if (newProgress != g.progress || (newProgress == 100 && !g.isDone)) {
        final updated = Goal(
          id: g.id,
          title: g.title,
          isDone: newProgress == 100,
          progress: newProgress,
          createdAt: g.createdAt,
          deadline: g.deadline,
          noteId: g.noteId,
          subtasks: g.subtasks,
        );

        await updateGoal(updated);
      }
    }

    return goals;
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    final result = await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
    await NotificationService.instance.scheduleGoal(goal);
    return result;
  }
}
