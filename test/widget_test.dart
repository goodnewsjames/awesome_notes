import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:awesome_notes/app.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:hive/hive.dart';

class FakeHiveService implements HiveService {
  @override
  Future<void> initialize() async {}

  @override
  Box get box => throw UnimplementedError();

  @override
  Future<void> saveNote(Note note) async {}

  @override
  Future<Note?> getNote(String noteId) async => null;

  @override
  Future<void> deleteNote(String noteId) async {}

  @override
  Future<List<Note>> loadAllNotes() async => [];

  @override
  Future<void> clearAllNotes() async {}
}

void main() {
  testWidgets('App builds without crashing', (
    WidgetTester tester,
  ) async {
    // Mock the HiveService
    final fakeHiveService = FakeHiveService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      AwesomeNoteApp(hiveService: fakeHiveService),
    );

    // Trigger a frame to allow providers to initialize
    await tester.pump();

    // Verify that the app builds (checking for a known widget or just absence of error)
    // MaterialApp should be present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
