import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:awesome_notes/services/cloud_service.dart';
import 'package:flutter/material.dart';

class TrashController extends ChangeNotifier {
  final HiveService _hiveService;
  final CloudService _cloudService;
  final List<Note> _trashNotes = [];

  TrashController(this._hiveService, this._cloudService);

  List<Note> get trashNotes => [..._trashNotes]
    ..sort(
      (a, b) => b.dateModified.compareTo(a.dateModified),
    );

  Future<void> loadTrashNotes() async {
    final notes = await _hiveService.loadAllNotes();
    _trashNotes.clear();
    _trashNotes.addAll(notes.where((n) => n.isDeleted));
    notifyListeners();
  }

  void clearTrash() {
    _trashNotes.clear();
    notifyListeners();
  }

  Future<void> restoreNote(Note note) async {
    final updatedNote = note.copyWith(
      isDeleted: false,
      needsSync: true,
      dateModified: DateTime.now(),
    );
    await _hiveService.saveNote(updatedNote);
    _trashNotes.removeWhere((n) => n.id == note.id);
    notifyListeners();
  }

  Future<void> deletePermanently(Note note) async {
    // 1. Remove from local Hive entirely
    await _hiveService.deleteNote(note.id);

    // 2. Remove from Cloud Firestore entirely
    await _cloudService.hardDeleteNote(note.id);

    // 3. Update local state
    _trashNotes.removeWhere((n) => n.id == note.id);
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    final notesToDelete = [..._trashNotes];
    for (final note in notesToDelete) {
      await deletePermanently(note);
    }
  }
}
