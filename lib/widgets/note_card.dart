import 'package:awesome_notes/change_notifiers/new_note_controller.dart';
import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/core/dialogs.dart';
import 'package:awesome_notes/core/utils/date_extensions.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/pages/new_or_edit_note_page.dart';
import 'package:awesome_notes/widgets/note_tag.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.isInGrid,
    required this.note,
  });
  final Note note;
  final bool isInGrid;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) =>
                  NewNoteController()..note = note,
              child: NewOrEditNotePage(isNewNote: false),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.5),
              offset: Offset(4, 4),
            ),
          ],
          color: white,
          border: Border.all(color: primary, width: 2),
          borderRadius: BorderRadius.circular(13),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null) ...[
              Text(
                note.title!,
                overflow: TextOverflow.visible,
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: grey900,
                ),
              ),
              SizedBox(height: 4),
            ],
            if (note.tags != null) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    note.tags!.length,
                    (index) =>
                        NoteTag(label: note.tags![index]),
                  ),
                ),
              ),
              SizedBox(height: 4),
            ],

            if (note.content != null)
              isInGrid
                  ? Expanded(
                      child: Text(
                        note.content!,
                        maxLines: 6,
                        overflow: TextOverflow.visible,
                        style: TextStyle(color: grey700),
                      ),
                    )
                  : Text(
                      note.content!,
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                      style: TextStyle(color: grey700),
                    ),
            if (isInGrid) Spacer(),
            Row(
              children: [
                Text(
                  formatShortDate(note.dateModified),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: grey500,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: ()async {
                 final shouldDelete = await   showConfirmationDialog(
                      context: context, dialog: "Do you want to delete this note?"
                    ) ?? false;


                    if(shouldDelete && context.mounted){
                      context
                          .read<NotesProvider>()
                          .deleteNote(note);
                    }
                   
                  },
                  child: FaIcon(
                    FontAwesomeIcons.trash,
                    color: grey500,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
