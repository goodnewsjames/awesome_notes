import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/enums/order_option.dart';
import 'package:awesome_notes/widgets/note_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ViewOptions extends StatefulWidget {
  const ViewOptions({super.key});

  @override
  State<ViewOptions> createState() => _ViewOptionsState();
}

class _ViewOptionsState extends State<ViewOptions> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (_, noteProvider, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            NoteIconButton(
              icon: noteProvider.isDecending
                  ? FontAwesomeIcons.arrowDown
                  : FontAwesomeIcons.arrowUp,
              onPressed: () {
                setState(() {
                  noteProvider.isDecending =
                      !noteProvider.isDecending;
                });
              },
            ),
            SizedBox(width: 16),
            DropdownButton<OrderOption>(
              underline: SizedBox.shrink(),
              borderRadius: BorderRadius.circular(16),
              icon: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: FaIcon(
                  FontAwesomeIcons.arrowDownWideShort,
                  size: 18,
                  color: grey700,
                ),
              ),
              selectedItemBuilder: (context) => OrderOption
                  .values
                  .map((e) => Text(e.name))
                  .toList(),
              value: noteProvider.orderBy,
              isDense: true,
              items: OrderOption.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Text(e.name),
                          if (e ==
                              noteProvider.orderBy) ...[
                            SizedBox(width: 8),
                            Icon(Icons.check),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                noteProvider.orderBy = newValue!;
              },
            ),
            Spacer(),
            NoteIconButton(
              size: 18,
              icon: noteProvider.isGrid
                  ? FontAwesomeIcons.tableCellsLarge
                  : FontAwesomeIcons.bars,
              onPressed: () {
                noteProvider.isGrid = !noteProvider.isGrid;
              },
            ),
          ],
        ),
      ),
    );
  }
}
