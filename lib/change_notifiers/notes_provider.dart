import 'package:awesome_notes/core/utils/extensions.dart';
import 'package:awesome_notes/enums/order_option.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  final HiveService _hiveService;

  NotesProvider(this._hiveService);
  List<Note> get notes =>
      [..._notes.where(_test)]..sort(_compare);

  bool _test(Note note) {
    final term = _searchTerm.toLowerCase().trim();
    final title = note.title?.toLowerCase() ?? "";
    final content = note.content?.toLowerCase() ?? "";
    final tags =
        note.tags?.map((e) => e.toLowerCase()).toList() ??
        [];

    return title.contains(term) ||
        content.contains(term) ||
        // tags.any((element) => element.contains(term));
        tags.deepContains(term);
  }

  int _compare(Note note1, Note note2) {
    if (_orderBy == OrderOption.dateModified) {
      return _isDecending
          ? note2.dateModified.compareTo(note1.dateModified)
          : note1.dateModified.compareTo(
              note2.dateModified,
            );
    } else {
      return _isDecending
          ? note2.dateCreated.compareTo(note1.dateCreated)
          : note1.dateCreated.compareTo(note2.dateCreated);
    }
  }

  Future<void> loadAllNotes() async {
    final notes = await _hiveService.loadAllNotes();
    _notes.clear();
    _notes.addAll(notes.where((n) => !n.isDeleted));
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    _hiveService.saveNote(note);
    notifyListeners();
  }

  void updateNote(Note note) {
    final now = DateTime.now();
    final index = _notes.indexWhere(
      (element) => element.dateCreated == note.dateCreated,
    );
    final updatedNote = note.copyWith(
      dateModified: now,
      needsSync: true,
    );
    _hiveService.saveNote(updatedNote);
    _notes[index] = updatedNote;
    notifyListeners();
  }

  void deleteNote(Note note) {
    _notes.remove(note);
    _hiveService.deleteNote(note.id);
    notifyListeners();
  }

  Future<void> clearAllNotes() async {
    _notes.clear();
    await _hiveService.clearAllNotes();
    notifyListeners();
  }

  OrderOption _orderBy = OrderOption.dateModified;
  set orderBy(OrderOption value) {
    _orderBy = value;
    notifyListeners();
  }

  OrderOption get orderBy => _orderBy;
  bool _isDecending = true;

  set isDecending(bool value) {
    _isDecending = value;
    notifyListeners();
  }

  bool get isDecending => _isDecending;

  bool _isGrid = true;

  set isGrid(bool value) {
    _isGrid = value;
    notifyListeners();
  }

  bool get isGrid => _isGrid;

  String _searchTerm = "";
  set searchTerm(String value) {
    _searchTerm = value;
    notifyListeners();
  }

  String get searchTerm => _searchTerm;
}
