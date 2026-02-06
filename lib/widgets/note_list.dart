import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/widgets/note_card.dart';
import 'package:flutter/material.dart';

class NoteList extends StatelessWidget {
  const NoteList({super.key, required this.notes});
  final List<Note> notes;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: 8),
      itemBuilder: (context, index) {
        return NoteCard(
          isInGrid: false,
          note: notes[index],
        );
      },
    );
  }
}
