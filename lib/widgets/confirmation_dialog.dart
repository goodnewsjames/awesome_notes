import 'package:awesome_notes/widgets/dialog_card.dart';
import 'package:awesome_notes/widgets/note_button.dart';
import 'package:flutter/material.dart';

class ConfrimationDialog extends StatelessWidget {
  const ConfrimationDialog({
    super.key,
    required this.dialogText,
  });
  final String dialogText;
  @override
  Widget build(BuildContext context) {
    return DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dialogText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NoteButton(
                isOutlined: true,
                onPressed: () =>
                    Navigator.pop(context, false),
                child: Text( "No",  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              NoteButton(
                child: Text("Yes",  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () =>
                    Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
