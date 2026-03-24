import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/pages/main_page.dart';
import 'package:awesome_notes/pages/registration_page.dart';
import 'package:awesome_notes/services/services.dart';
import 'package:awesome_notes/change_notifiers/change_notifiers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: primary,
            selectionHandleColor: primary,
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
         FleatherLocalizations.delegate,
        ],
        supportedLocales: FleatherLocalizations.supportedLocales,
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
