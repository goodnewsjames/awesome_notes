import 'package:awesome_notes/change_notifiers/new_note_controller.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/core/dialogs.dart';
import 'package:awesome_notes/widgets/note_back_button.dart';
import 'package:awesome_notes/widgets/note_icon_button_outlined.dart';
import 'package:awesome_notes/widgets/note_metadata.dart';
import 'package:awesome_notes/widgets/note_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NewOrEditNotePage extends StatefulWidget {
  const NewOrEditNotePage({
    super.key,
    required this.isNewNote,
  });

  final bool isNewNote;

  @override
  State<NewOrEditNotePage> createState() =>
      _NewOrEditNotePageState();
}

class _NewOrEditNotePageState
    extends State<NewOrEditNotePage> {
  late final NewNoteController newNoteController;
  late final TextEditingController titleController;
  late final QuillController quillController;
  late FocusNode contentFocusNode;
  late FocusNode titleFocusNode;

  @override
  void initState() {
    super.initState();
    newNoteController = context.read<NewNoteController>();
    quillController = QuillController.basic()
      ..addListener(() {
        newNoteController.content =
            quillController.document;
      });

    contentFocusNode = FocusNode();
    titleFocusNode = FocusNode();

    titleController = TextEditingController(
      text: newNoteController.title,
    );
    newNoteController.addListener(() {
      quillController.readOnly = newNoteController.readOnly;
    });
    WidgetsBinding.instance.addPostFrameCallback((
      timeStamp,
    ) {
      if (widget.isNewNote) {
        // focusNode.requestFocus();
        newNoteController.readOnly = false;
      } else {
        newNoteController.readOnly = true;
        quillController.document =
            newNoteController.content;
      }
      // newNoteController.readOnly = !widget.isNewNote;
    });
  }

  @override
  void dispose() {
    quillController.dispose();
    titleController.dispose();
    contentFocusNode.dispose();
    titleFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (!newNoteController.canSaveNote) {
          Navigator.pop(context);
          return;
        }

        final bool? shouldSave =
            await showConfirmationDialog(
              context: context,
              dialog: "Do you want to save the note?",
            );
        if (shouldSave == null) return;
        if (!context.mounted) return;
        if (shouldSave) {
          newNoteController.saveNote(context);
        }
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isNewNote ? "New Note" : "Edit Note",
          ),
          leading: NoteBackButton(),
          actions: [
            Selector<NewNoteController, bool>(
              selector: (context, newNoteController) =>
                  newNoteController.readOnly,
              builder: (context, readOnly, child) =>
                  NoteIconButtonOutlined(
                    icon: newNoteController.readOnly
                        ? FontAwesomeIcons.pen
                        : FontAwesomeIcons.bookOpen,
                    onPressed: () {
                      newNoteController.toggleReadOnly();
                      if (newNoteController.readOnly) {
                        FocusScope.of(context).unfocus();
                      } else {
                        contentFocusNode.requestFocus();
                      }
                    },
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Selector<NewNoteController, bool>(
                selector: (_, newNoteController) =>
                    newNoteController.canSaveNote,
                builder: (_, canSaveNote, _) =>
                    NoteIconButtonOutlined(
                      icon: FontAwesomeIcons.check,
                      onPressed: canSaveNote
                          ? () {
                              newNoteController.saveNote(
                                context,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                    ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Selector<NewNoteController, bool>(
                selector: (context, controller) =>
                    controller.readOnly,
                builder: (context, read, child) {
                  return TextFormField(

                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (newValue) {
                      newNoteController.title = newValue;
                    },
                    onFieldSubmitted: (value) {
                      contentFocusNode.requestFocus();
                    },
                    canRequestFocus: !read,
                    focusNode: titleFocusNode,
                    decoration: InputDecoration(
                      hintText: "Title here",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: grey300),
                    ),
                  );
                },
              ),
              NoteMetadata(note: newNoteController.note),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Divider(
                  color: grey500,
                  thickness: 2,
                  height: 32,
                ),
              ),
              Expanded(
                child: Selector<NewNoteController, bool>(
                  selector: (_, controller) =>
                      controller.readOnly,
                  builder: (_, readOnly, _) => Column(
                    children: [
                      Expanded(
                        child: QuillEditor.basic(
                          controller: quillController,
                          focusNode: contentFocusNode,

                          config: QuillEditorConfig(
                            placeholder: "Note here...",
                            expands: true,
                          ),
                        ),
                      ),
                      if (!readOnly)
                        NoteToolbar(
                          controller: quillController,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
