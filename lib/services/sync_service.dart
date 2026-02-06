import 'dart:async';
import 'package:awesome_notes/models/note.dart';
import 'package:awesome_notes/services/cloud_service.dart';
import 'package:awesome_notes/services/hive_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final CloudService _cloud;
  final HiveService _hive;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<QuerySnapshot>? _firestoreSub;
  StreamSubscription<List<ConnectivityResult>>?
  _conectivitySub;

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
    _setupFirestoreListener();

    _setupConnectivityListener();

    _pushPendingIfOnline();
  }

  void _setupFirestoreListener() {
    if (!_cloud.isLoggedIn) return;

    _firestoreSub = _cloud.notesSnapshots.listen((
      snapshot,
    ) async {
      for (final changes in snapshot.docChanges) {
        final doc = changes.doc;
        final data = doc.data();
        if (data == null) continue;

        final remoteNote = Note.fromMap(data, id: doc.id);

        final localNote = await _hive.getNote(
          remoteNote.id,
        );

        if (localNote == null) {
          if (!remoteNote.isDeleted) {
            await _hive.saveNote(
              remoteNote.copyWith(needsSync: false),
            );
          } else if (remoteNote.dateModified.isAfter(
            localNote!.dateModified,
          )) {
            if (remoteNote.isDeleted) {
              await _hive.deleteNote(remoteNote.id);
            } else {
              await _hive.saveNote(
                remoteNote.copyWith(needsSync: false),
              );
            }
          }
        }

        _notifyChanges?.call();
      }
    });
  }

  void _setupConnectivityListener() {
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
        if (note.isDeleted) {
          await _cloud.hardDeleteNote(note.id);
        } else {
          await _cloud.uploadNote(note);
        }
        await _hive.saveNote(
          note.copyWith(needsSync: false),
        );
      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }

  Future<void> forcePush() => _pushPendingIfOnline();

  void onLogin() {
    _setupFirestoreListener();
    _pushPendingIfOnline();
  }

  void onLogout() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  VoidCallback? _notifyChanges;
  void setOnChangeCallback(VoidCallback callback) {
    _notifyChanges = callback;
  }

  void dispose() {
    _firestoreSub?.cancel();
    _conectivitySub?.cancel();
  }
}
