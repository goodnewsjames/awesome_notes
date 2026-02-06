import 'package:awesome_notes/core/constants.dart';
import 'package:flutter/material.dart';

class NoteTag extends StatelessWidget {
  const NoteTag({
    super.key,
    required this.label,
    this.onClosed, this.onTap,
  });
  final String label;
  final VoidCallback? onClosed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 4),
      
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: grey100,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 12,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: onClosed != null ? 14 : 12,
                color: grey700,
              ),
            ),
      
            if (onClosed != null) ...[
              SizedBox(width: 4),
              GestureDetector(
                onTap: onClosed,
                child: Icon(Icons.close, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
