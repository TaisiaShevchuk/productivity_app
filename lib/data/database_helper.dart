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
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
  Future<void> deleteItem(String type, int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.transaction((txn) async {
      final cleanData = Map<String, dynamic>.from(data);
      cleanData.remove('id');

      await txn.insert('trash', {
        'type': type,
        'data': jsonEncode(cleanData),
        'deleted_at': DateTime.now().millisecondsSinceEpoch,
      });

      switch (type) {
        case "note":
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
          await txn.delete('notes', where: 'id = ?', whereArgs: [id]);
          break;
        case "task":
          await txn.delete('tasks', where: 'id = ?', whereArgs: [id]);
          break;
        case "habit":
          await txn.delete('habits', where: 'id = ?', whereArgs: [id]);
          break;
        case "goal":
          await txn.delete('goals', where: 'id = ?', whereArgs: [id]);
          break;
      }
    });

    if (type == 'task') await NotificationService.instance.cancelTask(id);
    if (type == 'goal') await NotificationService.instance.cancelGoal(id);
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

  Future<void> restoreFromTrash(Map<String, dynamic> item) async {
    final type = item['type'];
    final data = jsonDecode(item['data']);

    switch (type) {
      case "note":
        await insertNote(Note.fromMap(data));
        break;

      case "task":
        await insertTask(Task.fromMap(data));
        break;

      case "habit":
        await insertHabit(Habit.fromMap(data));
        break;

      case "goal":
        await insertGoal(Goal.fromMap(data));
        break;
    }

    await deleteFromTrash(item['id']);
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
