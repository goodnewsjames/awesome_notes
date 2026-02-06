import 'package:awesome_notes/widgets/dialog_card.dart';
import 'package:awesome_notes/widgets/note_button.dart';
import 'package:awesome_notes/widgets/note_form_field.dart';
import 'package:flutter/material.dart';

class NewTagDialog extends StatefulWidget {
  const NewTagDialog({super.key, this.tag});
  final String? tag;

  @override
  State<NewTagDialog> createState() => _NewTagDialogState();
}

class _NewTagDialogState extends State<NewTagDialog> {
  late final TextEditingController tagController;
  late final GlobalKey<FormFieldState> tagkey;

  @override
  void initState() {
    super.initState();
    tagController = TextEditingController(text: widget.tag);
    tagkey = GlobalKey();
  }

  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogCard(
      child: Form(
        key: tagkey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Add tag",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            NoteFormField(
              controller: tagController,
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return "No tads added";
                } else if (value.trim().length > 16) {
                  return "Tags should not be more than 16 characters";
                }
                return null;
              },
              onEditingComplete: () {
                if (tagkey.currentState?.validate() ??
                    false) {
                  Navigator.pop(
                    context,
                    tagController.text.trim(),
                  );
                }
              },
              hintText: "Add tag (< 16 characters)",
              autofocus: true,
              onChanged: (value) {
                tagkey.currentState?.validate();
              },
            ),
            SizedBox(height: 24),
            NoteButton(
              child: Text( "Add",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (tagkey.currentState?.validate() ??
                    false) {
                  Navigator.pop(
                    context,
                    tagController.text.trim(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
 