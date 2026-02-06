import 'package:awesome_notes/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CloudService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  CollectionReference<Map<String, dynamic>>
  get _notesCollection {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception(
        'User is not authenticated - cannot access notes collection',
      );
    }
    return _firestore
        .collection("users")
        .doc(uid)
        .collection('notes');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
  get notesSnapshots {
    if (!isLoggedIn) {
      return Stream.empty();
    }
    return _notesCollection.snapshots();
  }

  Future<void> uploadNote(Note note) async {
    if (!isLoggedIn) {
      debugPrint("Cannot upload note - User not logged in");
      return;
    }

    try {
      final docRef = _notesCollection.doc(note.id);
      await docRef.set(note.toMap());
      debugPrint(
        "Uploaded note ${note.id} (isDeleted: ${note.isDeleted})",
      );
    } catch (e) {
      debugPrint("Failed to upload note ${note.id}: $e");
      rethrow;
    }
  }

  Future<void> hardDeleteNote(String noteId) async {
    if (!isLoggedIn) {
      debugPrint("Cannot delete note - user not logged in");
      return;
    }

    try {
      await _notesCollection.doc(noteId).delete();
      debugPrint("Hard deleted note $noteId from cloud");
    } catch (e) {
      debugPrint("Failed to hard delete note $noteId: $e");
      rethrow;
    }
  }
}
