import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/change_notifiers/registration_controller.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/pages/main_page.dart';
import 'package:awesome_notes/pages/registration_page.dart';
import 'package:awesome_notes/services/auth_service.dart';
import 'package:awesome_notes/services/cloud_service.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:awesome_notes/services/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_notes/change_notifiers/trash_controller.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

class AwesomeNoteApp extends StatelessWidget {
  final HiveService hiveService;
  final Widget? home;
  const AwesomeNoteApp({
    required this.hiveService,
    this.home,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: hiveService),
        Provider<CloudService>(
          create: (_) => CloudService(),
        ),
        Provider<SyncService>(
          lazy: false,
          create: (context) {
            final cloud = context.read<CloudService>();
            final hive = context.read<HiveService>();
            return SyncService(cloud: cloud, hive: hive);
          },
          dispose: (_, sync) => sync.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = NotesProvider(
              context.read<HiveService>(),
            );
            context.read<SyncService>().addListener(() {
              provider.loadAllNotes();
            });
            return provider..loadAllNotes();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final controller = TrashController(
              context.read<HiveService>(),
              context.read<CloudService>(),
            );
            context.read<SyncService>().addListener(() {
              controller.loadTrashNotes();
            });
            return controller..loadTrashNotes();
          },
        ),
        ChangeNotifierProvider(
          create: (context) => RegistrationController(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Awesome Notes',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
          ),
          scaffoldBackgroundColor: background,
          appBarTheme: Theme.of(context).appBarTheme
              .copyWith(
                backgroundColor: Colors.transparent,
                titleTextStyle: GoogleFonts.fredoka(
                  color: primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        localizationsDelegates: [
          FlutterQuillLocalizations.delegate,
        ],
        home:
            home ??
            StreamBuilder<User?>(
              stream: AuthService.userStream,
              builder: (context, snapshot) {
                return snapshot.hasData &&
                        AuthService.isEmailVerified
                    ? MainPage()
                    : RegistrationPage();
              },
            ),
      ),
    );
  }
}
