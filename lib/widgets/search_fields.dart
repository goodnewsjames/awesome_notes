import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController searchController;
  late final NotesProvider notesProvider;

  @override
  void initState() {
    super.initState();
    notesProvider = context.read();
    searchController = TextEditingController()
      ..addListener(() {
        notesProvider.searchTerm = searchController.text;
      });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        prefixIconConstraints: BoxConstraints(
          minHeight: 42,
          minWidth: 42,
        ),
        suffixIconConstraints: BoxConstraints(
          minHeight: 42,
          minWidth: 42,
        ),
        contentPadding: EdgeInsets.zero,
        isDense: true,
        fillColor: white,
        filled: true,
        hintText: "Search Notes...",
        prefixIcon: Icon(
          FontAwesomeIcons.magnifyingGlass,
          size: 16,
        ),
        suffixIcon: ListenableBuilder(
          listenable: searchController,
          builder: (context, clearButton) =>
              searchController.text.isNotEmpty
              ? clearButton!
              : const SizedBox.shrink(),
              child: GestureDetector(
            onTap: () {
              searchController.clear();
            },
            child: Icon(FontAwesomeIcons.circleXmark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary),
        ),
      ),
    );
  }
}
