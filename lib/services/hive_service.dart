import 'package:awesome_notes/models/note.dart';
import 'package:hive/hive.dart';

class HiveService {
  late final Box _box;
  static const String _indexKey = "notes_index";
   Box get box => _box;


   Future<void> initialize() async {
    await Hive.deleteBoxFromDisk('notebox');

    _box = await Hive.openBox("notebox");
  }

   Future<void> _addToIndex(String noteId) async {
    final index = _getIndex();

    if (index.contains(noteId)) {
      return;
    }
    final updatedIndex = [...index, noteId];
    await _box.put("notes_index", updatedIndex);
  }

   Future<void> _removeFromIndex(
    String noteId,
  ) async {
    final index = _getIndex();
    index.remove(noteId);
    await _box.put(_indexKey, index);
  }

   List<String> _getIndex() {
    final data = _box.get(_indexKey);
    if (data == null) return <String>[];
    if (data is List) return List<String>.from(data);
    return <String>[];
  }

   Future<void> saveNote(Note note) async {
    await _box.put(note.id, note);
    await _addToIndex(note.id);
  }

   Future<Note?> getNote(String noteId) async {
    return _box.get(noteId) as Note?;
  }

   Future<void> deleteNote(String noteId) async {
    await _removeFromIndex(noteId);
    await _box.delete(noteId);
  }

   Future<List<Note>> loadAllNotes() async {
    final noteIdList = _getIndex();
    final notes = <Note>[];

    for (String noteId in noteIdList) {
      final note = _box.get(noteId) as Note?;
      if (note != null) {
        notes.add(note);
      }
    }
    return notes;
  }

   Future<void> clearAllNotes() async {
    await _box.clear();
  }
  
}
