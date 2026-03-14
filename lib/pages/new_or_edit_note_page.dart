import 'dart:async' show Timer;

import 'package:awesome_notes/change_notifiers/new_note_controller.dart';
import 'package:awesome_notes/core/core.dart';
import 'package:awesome_notes/widgets/widgets.dart';
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
    extends State<NewOrEditNotePage>
    with WidgetsBindingObserver {
  late final NewNoteController newNoteController;
  late final TextEditingController titleController;
  late final QuillController quillController;
  late final FocusNode titleFocusNode;
  late final FocusNode contentFocusNode;
  late final ScrollController scrollController;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scrollController = ScrollController();
    newNoteController = context.read<NewNoteController>();
    quillController = QuillController.basic();
    quillController.addListener(_startAutoSaveTimer);
    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
    titleController = TextEditingController(
      text: newNoteController.title,
    );
    WidgetsBinding.instance.addPostFrameCallback((
      timeStamp,
    ) {
      newNoteController.readOnly = true;
      if (widget.isNewNote) {
        newNoteController.readOnly = false;
        titleFocusNode.requestFocus();
      } else {
        quillController.document =
            newNoteController.content;

        final length = quillController.document.length;
        quillController.updateSelection(
          TextSelection.collapsed(offset: length - 1),
          ChangeSource.local,
        );
        contentFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _saveNote();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    quillController.dispose();
    titleController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), () {
      if (newNoteController.canSaveNote) {
        _saveNote();
      }
    });
  }

  void _saveNote() {
    newNoteController.content = quillController.document;
    if (newNoteController.canSaveNote) {
      newNoteController.saveNote(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _autoSaveTimer?.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _saveNote();
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                    onPressed: () {},
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
                              newNoteController.content =
                                  quillController.document;
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
        body: Selector<NewNoteController, bool>(
          selector: (context, newNoteController) =>
              newNoteController.readOnly,
          builder: (context, readOnly, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              TextFormField(
                                focusNode: titleFocusNode,
                                controller: titleController,
                                maxLines: 2,

                                textCapitalization:
                                    TextCapitalization
                                        .words,
                                textInputAction:
                                    TextInputAction.next,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                onChanged: (newValue) {
                                  newNoteController.title =
                                      newValue;
                                },
                                decoration: InputDecoration(
                                  hintText: "Title here",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: grey300,
                                  ),
                                ),
                              ),
                              NoteMetadata(
                                note:
                                    newNoteController.note,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                child: Divider(
                                  color: grey500,
                                  thickness: 2,
                                  height: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: QuillEditor.basic(
                            focusNode: contentFocusNode,
                            controller: quillController,
                            config: QuillEditorConfig(
                              placeholder: "Note here...",
                              expands: true,
                              showCursor: true,
                              scrollable: true,
                              enableSelectionToolbar: true,
                              enableInteractiveSelection:
                                  true,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(
                            context,
                          ).viewInsets.bottom +
                          16,
                      left: 16,
                      right: 16,
                    ),
                    child: NoteToolbar(
                      controller: quillController,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
