import 'package:awesome_notes/core/constants.dart';
import 'package:flutter/material.dart';

class NoteButton extends StatelessWidget {
  const NoteButton({
    super.key,

    required this.child,
    this.onPressed,
    this.isOutlined = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      
      decoration: BoxDecoration(
        color: primary,
        boxShadow: [
          BoxShadow(
            offset: Offset(2, 2),
            color: isOutlined ? primary : black,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: grey300,
          disabledForegroundColor: black,
          backgroundColor: isOutlined ? white : primary,
          foregroundColor: isOutlined ? primary : white,
          side: BorderSide(
            color: isOutlined ? primary : black,
          ),
          elevation: 0,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: child,
      ),
    );
  }
}
