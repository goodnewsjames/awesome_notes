import 'package:awesome_notes/change_notifiers/new_note_controller.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/core/dialogs.dart';
import 'package:awesome_notes/core/utils/date_extensions.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/widgets/note_icon_button.dart';
import 'package:awesome_notes/widgets/note_tag.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NoteMetadata extends StatefulWidget {
  const NoteMetadata({super.key, required this.note});
  final Note? note;

  @override
  State<NoteMetadata> createState() => _NoteMetadataState();
}

class _NoteMetadataState extends State<NoteMetadata> {
  late final NewNoteController newNoteController;

  @override
  void initState() {
    super.initState();
    newNoteController = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.note != null) ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Last Modified",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: grey500,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  formatLongDate(widget.note!.dateModified),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: grey900,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Created",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: grey500,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  formatLongDate(widget.note!.dateCreated),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: grey900,
                  ),
                ),
              ),
            ],
          ),
        ],
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  const Text(
                    "Tags",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: grey500,
                    ),
                  ),
                  SizedBox(width: 8),
                  NoteIconButton(
                    icon: FontAwesomeIcons.circlePlus,
                    onPressed: () async {
                      final String? tag =
                          await showNewTagDialog(
                            context: context,
                          );
                      if (tag != null) {
                        newNoteController.addTags(tag);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Selector<NewNoteController, List<String>>(
                selector: (context, newNoteController) =>
                    newNoteController.tags,
                builder: (_, tags, _) => tags.isEmpty
                    ? const Text(
                        "No tags added",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: grey900,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            tags.length,
                            (index) => NoteTag(
                              label: tags[index],
                              onClosed: () {
                                newNoteController.removeTag(
                                  index,
                                );
                              },
                              onTap: () async {
                                final String? tag =
                                    await showNewTagDialog(
                                      context: context,
                                      tag: tags[index],
                                    );

                                if (tag != null &&
                                    tag != tags[index]) {
                                  newNoteController
                                      .updateTag(tag, index);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
