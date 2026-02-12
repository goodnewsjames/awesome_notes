import 'package:awesome_notes/app.dart';
import 'package:awesome_notes/firebase_options.dart';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/services/auth_service.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.initialize();

  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  final HiveService hiveService = HiveService();
  await hiveService.initialize();

  runApp(AwesomeNoteApp(hiveService: hiveService));
}
// (Factory, Singleton, Observer)