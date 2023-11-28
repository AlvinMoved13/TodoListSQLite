import 'package:flutter/material.dart';

import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NoteApp(),
    );
  }
}

class NoteApp extends StatefulWidget {
  @override
  _NoteAppState createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<Map<String, String?>> notes = [];
  final NoteDatabaseHelper _databaseHelper = NoteDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    await _databaseHelper.open();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    List<Map<String, dynamic>> notesFromDatabase =
        await _databaseHelper.getAllNotes();
    setState(() {
      notes = List<Map<String, String?>>.from(
        notesFromDatabase.map((note) {
          return {
            'title': note['title'].toString(),
            'content': note['content'].toString(),
          };
        }),
      );
    });
  }

  Future<void> _searchNotes(String query) async {
    List<Map<String, dynamic>> searchResults =
        await _databaseHelper.searchNotes(query);
    setState(() {
      notes = List<Map<String, String?>>.from(
        searchResults.map((note) {
          return {
            'title': note['title'].toString(),
            'content': note['content'].toString(),
          };
        }),
      );
    });
  }

  Future<void> _saveNote() async {
    String title = titleController.text;
    String content = contentController.text;

    if (title.isNotEmpty || content.isNotEmpty) {
      await _databaseHelper.insertNote({'title': title, 'content': content});
      titleController.clear();
      contentController.clear();
      _refreshNotes();
    }
  }

  Future<void> _getNotes() async {
    _refreshNotes();
  }

  Future<void> _deleteNote(int index) async {
    await _databaseHelper.deleteNote(notes[index]['title']!);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Catatan'),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Judul Catatan'),
            ),
          ),
          ListTile(
            title: TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Isi Catatan'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    titleController.clear();
                    contentController.clear();
                  });
                },
                icon: Icon(Icons.delete, color: Colors.black54),
                label: Text('Clear', style: TextStyle(color: Colors.black)),
              ),
              SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _saveNote,
                icon: Icon(Icons.save, color: Colors.black54),
                label: Text('Save', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(30.0), // Border circular bulat
              color: Colors.grey[300],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.black54), // Logo 'search'
                SizedBox(width: 10.0), // Ruang antara logo dan TextField
                Expanded(
                  child: TextField(
                    onChanged: _searchNotes,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: ListTile(
                    title: Text(note['title'] ?? ''),
                    subtitle: Text(note['content'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(index),
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
}
