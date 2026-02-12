import 'package:awesome_notes/change_notifiers/new_note_controller.dart';
import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/change_notifiers/trash_controller.dart';
import 'package:awesome_notes/core/dialogs.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/pages/new_or_edit_note_page.dart';
import 'package:awesome_notes/services/auth_service.dart';
import 'package:awesome_notes/widgets/no_notes.dart';
import 'package:awesome_notes/widgets/note_fab.dart';
import 'package:awesome_notes/widgets/note_grid.dart';
import 'package:awesome_notes/widgets/note_icon_button_outlined.dart';
import 'package:awesome_notes/widgets/note_list.dart';
import 'package:awesome_notes/widgets/search_fields.dart';
import 'package:awesome_notes/widgets/view_options.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Awesome Notes 📒"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: NoteIconButtonOutlined(
              icon: FontAwesomeIcons.rightFromBracket,
              onPressed: () async {
                final bool shouldLogout =
                    await showConfirmationDialog(
                      context: context,
                      dialog:
                          "Do you want to sign out of the app?",
                    ) ??
                    false;
                if (shouldLogout && context.mounted) {
                  final notesProvider =
                      Provider.of<NotesProvider>(
                        context,
                        listen: false,
                      );
                  final trashController =
                      Provider.of<TrashController>(
                        context,
                        listen: false,
                      );

                  await notesProvider.clearAllNotes();
                  trashController.clearTrash();
                  await AuthService.logout();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: NoteFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => NewNoteController(),
                child: NewOrEditNotePage(isNewNote: true),
              ),
            ),
          );
        },
      ),
      body: Consumer<NotesProvider>(
        builder: (context, noteProvider, child) {
          final List<Note> notes = noteProvider.notes;
          return notes.isEmpty &&
                  noteProvider.searchTerm.isEmpty
              ? const NoNotes()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SearchField(),
                      if (notes.isNotEmpty) ...[
                        const ViewOptions(),
                        Expanded(
                          child: noteProvider.isGrid
                              ? NoteGrid(notes: notes)
                              : NoteList(notes: notes),
                        ),
                      ] else
                        Expanded(
                          child: Center(
                            child: Text(
                              'No notes found for your query!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
