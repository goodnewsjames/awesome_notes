import 'package:awesome_notes/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({super.key, required this.controller});
  final QuillController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: white,
        border: Border.all(
          color: primary,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: primary, offset: Offset(4, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            QuillToolbarHistoryButton(
              controller: controller,
              isUndo: true,
              options: QuillToolbarHistoryButtonOptions(
                iconData: FontAwesomeIcons.arrowRotateLeft,
                iconSize: 12,
              ),
            ),
            QuillToolbarHistoryButton(
              controller: controller,
              isUndo: false,
              options: QuillToolbarHistoryButtonOptions(
                iconData: FontAwesomeIcons.arrowRotateRight,
                iconSize: 12,

              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.bold,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: FontAwesomeIcons.bold,
                iconSize: 12,

              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.italic,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: FontAwesomeIcons.italic,
                iconSize: 12,

              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.underline,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: FontAwesomeIcons.underline,
                iconSize: 12,

              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.strikeThrough,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: FontAwesomeIcons.strikethrough,
              ),
            ),
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
              options: QuillToolbarColorButtonOptions(
                iconData: FontAwesomeIcons.palette,
                iconSize: 12,

              ),
            ),
            QuillToolbarColorButton(
              controller: controller,
              isBackground: true,
              options: QuillToolbarColorButtonOptions(
                iconData: FontAwesomeIcons.fillDrip,
                iconSize: 12,

              ),
            ),
            QuillToolbarClearFormatButton(
              controller: controller,
              options: QuillToolbarClearFormatButtonOptions(
                iconData: FontAwesomeIcons.textSlash,
                iconSize: 12,

              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.ol,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: FontAwesomeIcons.listOl,
                iconSize: 12,

              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.ul,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: FontAwesomeIcons.listUl,
                iconSize: 12,

              ),
            ),
            QuillToolbarSearchButton(
              controller: controller,
              options: QuillToolbarSearchButtonOptions(
                iconData: FontAwesomeIcons.magnifyingGlass,
                iconSize: 12,

              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*

QuillSimpleToolbar(
        controller: controller,
        config: QuillSimpleToolbarConfig(
          multiRowsDisplay: false,
          showFontFamily: false,
          showFontSize: false,
          showSuperscript: false,
          showSubscript: false,
          showSmallButton: false,
          showInlineCode: false,
          showAlignmentButtons: false,
          showDirection: false,
          showHeaderStyle: false,
          showListCheck: false,
          showDividers: false,
          showCodeBlock: false,
          showQuote: false,
          showIndent: false,
          showLink: false,
          showClipboardCopy: false,
          showClipboardCut: false,
          showClipboardPaste: false,
          buttonOptions: QuillSimpleToolbarButtonOptions(
            undoHistory: QuillToolbarHistoryButtonOptions(
              iconData: FontAwesomeIcons.arrowRotateLeft,
              iconSize: 22,
            ),
            redoHistory: QuillToolbarHistoryButtonOptions(
              iconData: FontAwesomeIcons.arrowRotateLeft,
              iconSize: 22,
            ),
            bold: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.bold,
              iconSize: 22,
            ),
            italic: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.italic,
              iconSize: 22,
            ),
            underLine: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.underline,
              iconSize: 22,
            ),
            strikeThrough:
                QuillToolbarToggleStyleButtonOptions(
                  iconData: FontAwesomeIcons.strikethrough,
                  iconSize: 22,
                ),
            color: QuillToolbarColorButtonOptions(
              iconData: FontAwesomeIcons.pallet,
              iconSize: 22,
            ),
            backgroundColor: QuillToolbarColorButtonOptions(
              iconData: FontAwesomeIcons.fillDrip,
              iconSize: 22,
            ),
            clearFormat:
                QuillToolbarClearFormatButtonOptions(
                  iconData: FontAwesomeIcons.textSlash,
                  iconSize: 22,
                ),
            listNumbers:
                QuillToolbarToggleStyleButtonOptions(
                  iconData: FontAwesomeIcons.listOl,
                  iconSize: 22,
                ),
            listBullets:
                QuillToolbarToggleStyleButtonOptions(
                  iconData: FontAwesomeIcons.listUl,
                  iconSize: 22,
                ),
            search: QuillToolbarSearchButtonOptions(
              iconData: FontAwesomeIcons.magnifyingGlass,
              iconSize: 22,
            ),
          ),
        ),
      ),

*/