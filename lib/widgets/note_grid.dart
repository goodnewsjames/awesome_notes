import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/widgets/note_card.dart';
import 'package:flutter/material.dart';

class NoteGrid extends StatelessWidget {
  const NoteGrid({super.key, required this.notes});
  final List<Note> notes;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      clipBehavior: Clip.none,
      itemCount: notes.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
      itemBuilder: (context, index) {
        return  NoteCard(isInGrid: true, note: notes[index],
        );
      },
    );
  }
}
