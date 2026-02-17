import 'dart:async';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/services/auth_service.dart';
import 'package:awesome_notes/services/cloud_service.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SyncService {
  final CloudService _cloud;
  final HiveService _hive;
  final List<VoidCallback> _listeners = [];
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<QuerySnapshot>? _firestoreSub;
  StreamSubscription<List<ConnectivityResult>>?
  _conectivitySub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<BoxEvent>? _hiveSub;

  // ignore: prefer_final_fields
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  SyncService({
    required CloudService cloud,
    required HiveService hive,
  }) : _cloud = cloud,
       _hive = hive {
    _startListening();
  }

  void _startListening() {
    // Listen to Auth Changes
    _authSub = AuthService.userStream.listen((user) {
      if (user != null) {
        _isOnline =
            true; // Assume online on login initially
        _setupFirestoreListener();
        _setupConnectivityListener();
        _setupLocalListener();
        _pushPendingIfOnline();
      } else {
        _cleanupListeners();
      }
    });
  }

  void _cleanupListeners() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
    _conectivitySub?.cancel();
    _conectivitySub = null;
    _hiveSub?.cancel();
    _hiveSub = null;
  }

  void _setupLocalListener() {
    _hiveSub = _hive.box.watch().listen((event) async {
      if (!_isOnline || !_cloud.isLoggedIn) return;

      // If key is string, it's a note ID (likely).
      // If event.value is null, it was deleted.
      // If event.value is Note, it was added/updated.

      if (event.key is String) {
        try {
          if (event.value is Note) {
            final note = event.value as Note;
            if (note.needsSync) {
              await _cloud.uploadNote(note);
              // Update local to remove needsSync flag
              await _hive.saveNote(
                note.copyWith(needsSync: false),
              );
            }
          }
        } catch (e) {
          debugPrint(
            "Error in SyncService local listener: $e",
          );
        }
      }
    });
  }

  void _setupFirestoreListener() {
    // ... same as before but ensure we don't double subscribe ...
    _firestoreSub?.cancel();
    _firestoreSub = _cloud.notesSnapshots.listen((
      snapshot,
    ) async {
      debugPrint(
        "SyncService: Received ${snapshot.docChanges.length} changes from Firestore",
      );
      for (final changes in snapshot.docChanges) {
        final doc = changes.doc;
        final data = doc.data();
        if (data == null) continue;

        try {
          final remoteNote = Note.fromMap(data, id: doc.id);

          final localNote = await _hive.getNote(
            remoteNote.id,
          );

          if (localNote == null) {
            debugPrint(
              "SyncService: Downloading remote note ${remoteNote.id} (isDeleted: ${remoteNote.isDeleted})",
            );
            await _hive.saveNote(
              remoteNote.copyWith(needsSync: false),
            );
          } else {
            // Conflict resolution
            if (remoteNote.isDeleted &&
                !localNote.isDeleted) {
              debugPrint(
                "SyncService: Marking local note ${remoteNote.id} as deleted (remote tombstone)",
              );
              await _hive.saveNote(
                remoteNote.copyWith(needsSync: false),
              );
            } else if (!remoteNote.isDeleted &&
                localNote.isDeleted) {
              // Remote is NOT deleted, but local IS. Check who is newer.
              if (remoteNote.dateModified.isAfter(
                localNote.dateModified,
              )) {
                debugPrint(
                  "SyncService: Resurrecting note ${remoteNote.id} (remote edit newer than local delete)",
                );
                await _hive.saveNote(
                  remoteNote.copyWith(needsSync: false),
                );
              }
            } else if (remoteNote.dateModified.isAfter(
              localNote.dateModified,
            )) {
              debugPrint(
                "SyncService: Updating local note ${remoteNote.id} (remote newer)",
              );
              await _hive.saveNote(
                remoteNote.copyWith(needsSync: false),
              );
            }
          }
        } catch (e) {
          debugPrint(
            "SyncService: Error processing remote change for ${doc.id}: $e",
          );
        }
      }
      _notifyListeners(); // Moved outside the loop
    });
  }

  void _setupConnectivityListener() {
    _conectivitySub?.cancel();
    _conectivitySub = _connectivity.onConnectivityChanged
        .listen((results) {
          final previous = _isOnline;

          _isOnline = results.any(
            (r) => r != ConnectivityResult.none,
          );

          if (_isOnline && !previous) {
            _pushPendingIfOnline();
          }
        });
  }

  Future<void> _pushPendingIfOnline() async {
    if (!_isOnline || !_cloud.isLoggedIn) return;

    final pendingUploads = (await _hive.loadAllNotes())
        .where((note) => note.needsSync)
        .toList();

    if (pendingUploads.isEmpty) return;

    for (final note in pendingUploads) {
      try {
        // Always upload the note, the isDeleted flag determines state in cloud
        await _cloud.uploadNote(note);
        await _hive.saveNote(
          note.copyWith(needsSync: false),
        );
      } catch (e) {
        debugPrint(
          "SyncService: Error in pushPendingIfOnline for ${note.id}: $e",
        );
      }
    }
  }

  Future<void> forcePush() => _pushPendingIfOnline();

  // Deprecated/Unused now handled by auth listener
  void onLogin() {}
  void onLogout() {}

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in [..._listeners]) {
      listener();
    }
  }

  // Deprecated: keeping for compatibility during transition if needed
  void setOnChangeCallback(VoidCallback callback) {
    addListener(callback);
  }

  void dispose() {
    _authSub?.cancel();
    _cleanupListeners();
  }
}
