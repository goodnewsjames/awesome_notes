import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({
    super.key,
    required this.controller,
    required this.editorKey,
  });
  final FleatherController controller;
  final GlobalKey<EditorState> editorKey;

  @override
  Widget build(BuildContext context) {
    return FleatherToolbar.basic(
      padding: EdgeInsets.zero,
      controller: controller,
      editorKey: editorKey,
      hideHeadingStyle: true,
      hideAlignment: true,
      hideIndentation: true,
      hideLink: true,
    );
  }
}