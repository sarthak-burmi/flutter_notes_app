import 'package:flutter_notes_app/models/note_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class NotesService {
  static const String _boxName = 'notes';
  late Box<HiveNote> _notesBox;
  final _uuid = Uuid();

  // Stream controllers
  final _notesStreamController = BehaviorSubject<List<Note>>();
  Stream<List<Note>> get notesStream => _notesStreamController.stream;

  // Initialize the service
  Future<void> initialize() async {
    // Open the notes box
    _notesBox = await Hive.openBox<HiveNote>(_boxName);

    // Initialize the stream with current notes
    _refreshNotesStream();
  }

  // Refresh the notes stream with latest data
  void _refreshNotesStream() {
    final notes =
        _notesBox.values.map((hiveNote) => hiveNote.toNote()).toList();
    _notesStreamController.add(notes);
  }

  // Get all notes
  List<Note> getAllNotes() {
    return _notesBox.values.map((hiveNote) => hiveNote.toNote()).toList();
  }

  // Get note by id
  // Get note by id
  Note? getNoteById(String id) {
    try {
      final hiveNote = _notesBox.values.firstWhere((note) => note.id == id);
      return hiveNote.toNote();
    } catch (e) {
      // Not found
      return null;
    }
  }

  // Create a new note
  Future<Note> createNote({
    required String title,
    required String content,
    String? category,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      category: category,
      createdAt: now,
      updatedAt: now,
    );

    // Save to Hive
    await _notesBox.put(note.id, HiveNote.fromNote(note));

    // Refresh stream
    _refreshNotesStream();

    return note;
  }

  // Update an existing note
  Future<Note> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());

    // Save to Hive
    await _notesBox.put(note.id, HiveNote.fromNote(updatedNote));

    // Refresh stream
    _refreshNotesStream();

    return updatedNote;
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);

    // Refresh stream
    _refreshNotesStream();
  }

  // Search notes by query
  List<Note> searchNotes(String query, {String? categoryFilter}) {
    final notes = getAllNotes();

    if (query.isEmpty && categoryFilter == null) {
      return notes;
    }

    // Filter by search query
    var filteredNotes =
        notes.where((note) {
          final matchesQuery =
              query.isEmpty ||
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase());

          final matchesCategory =
              categoryFilter == null || note.category == categoryFilter;

          return matchesQuery && matchesCategory;
        }).toList();

    return filteredNotes;
  }

  // Get all available categories
  List<String?> getAllCategories() {
    final categories =
        _notesBox.values.map((hiveNote) => hiveNote.category).toSet().toList();

    // Sort categories and put null at the end
    categories.sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });

    return categories;
  }

  // Dispose resources
  void dispose() {
    _notesStreamController.close();
  }
}
