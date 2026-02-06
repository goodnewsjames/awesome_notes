import 'package:awesome_notes/widgets/dialog_card.dart';
import 'package:awesome_notes/widgets/note_button.dart';
import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  const MessageDialog({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
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
                onPressed: () => Navigator.pop(context),
                child: Text( "OK",  style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
