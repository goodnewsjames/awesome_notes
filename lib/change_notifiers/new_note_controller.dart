import 'dart:convert';

import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notes/core/utils/id_generator.dart';

class NewNoteController extends ChangeNotifier {
  Note? _note;
  set note(Note? value) {
    _note = value;
    _title = _note!.title ?? "";
    _content = Document.fromJson(
      jsonDecode(_note!.contentJson),
    );
    _tags.addAll(_note!.tags ?? []);
    notifyListeners();
  }

  Note? get note => _note;
  bool _readOnly = false;

  bool get readOnly => _readOnly;

  void toggleReadOnly() {
    _readOnly = !readOnly;
    notifyListeners();
  }

  set readOnly(bool value) {
    _readOnly = value;
    notifyListeners();
  }

  String _title = "";

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  String get title => _title.trim();

  Document _content = Document();

  set content(Document value) {
    _content = value;
    notifyListeners();
  }

  Document get content => _content;

  List<String> _tags = [];

  void addTags(String tag) {
    if (tag.isNotEmpty) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  List<String> get tags => [..._tags];

  void removeTag(int index) {
    _tags.removeAt(index);
    notifyListeners();
  }

  void updateTag(String tag, index) {
    _tags[index] = tag;
    notifyListeners();
  }

  bool get isNewNote => _note == null;

  bool get canSaveNote {
    final String? newTitle = title.isNotEmpty
        ? title
        : null;
    final String? newContent =
        content.toPlainText().trim().isNotEmpty
        ? content.toPlainText().trim()
        : null;

    bool canSave = newTitle != null || newContent != null;
    if (!isNewNote) {
      final newContentJson = jsonEncode(
        content.toDelta().toJson(),
      );
      canSave &=
          newTitle != note!.title ||
          newContentJson != note!.contentJson ||
          !listEquals(tags, note!.tags);
    }

    return canSave;

    // if (isNewNote) {
    //   return newTitle != null || newContent != null;
    // } else {
    //   final newContentJson = jsonEncode(
    //     content.toDelta().toJson(),
    //   );
    //   return (newTitle != note!.title ||
    //           newContentJson != note!.contentJson ||
    //           !listEquals(tags, note!.tags)) &&
    //       (newTitle != null || newContent != null);
    // }
  }

  void saveNote(BuildContext context) {
    final String? newTitle = title.isNotEmpty
        ? title
        : null;
    final String? newContent =
        content.toPlainText().trim().isNotEmpty
        ? content.toPlainText().trim()
        : null;
    final String contentJson = jsonEncode(
      content.toDelta().toJson(),
    );
    final DateTime now = DateTime.now();
    // Reuse existing ID if not a new note, otherwise generate a new one
    final String activeId = isNewNote
        ? IdGenerator.generate()
        : _note!.id;

    final Note note = Note(
      id: activeId,
      title: newTitle,
      content: newContent,
      contentJson: contentJson,
      dateCreated: isNewNote ? now : _note!.dateCreated,
      dateModified: now,
      tags: tags,
    );

    _note = note;
    _title = note.title ?? '';
    _content = Document.fromJson(
      jsonDecode(note.contentJson),
    );
    _tags = [...note.tags ?? []];
    notifyListeners();

    final notesProvider = context.read<NotesProvider>();
    isNewNote
        ? notesProvider.addNote(note)
        : notesProvider.updateNote(note);
  }
}
