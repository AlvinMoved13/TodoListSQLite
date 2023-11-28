import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabaseHelper {
  late Database _database;

  Future<void> open() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  Future<int> insertNote(Map<String, String?> note) async {
    return await _database.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    return await _database.query('notes');
  }

  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    return await _database.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  Future<int> deleteNote(String title) async {
    return await _database
        .delete('notes', where: 'title = ?', whereArgs: [title]);
  }

  Future<void> close() async {
    await _database.close();
  }
}
