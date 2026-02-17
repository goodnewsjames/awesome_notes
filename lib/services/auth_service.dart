import 'package:awesome_notes/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;

  static Future<void> initialize() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  static User? get user => _auth.currentUser;
  static bool get isAuthenticated => user != null;

  static Stream<User?> get userStream =>
      _auth.userChanges();

  static bool get isEmailVerified =>
      user?.emailVerified ?? false;

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      final user = credential.user;
      if (user != null) {
        await user.sendEmailVerification();
        await user.updateDisplayName(fullName);
        await user.reload();
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Web: Use signInWithPopup directly from FirebaseAuth (handles GIS popup/webview)
    if (kIsWeb) {
      try {
        return await _auth.signInWithPopup(
          GoogleAuthProvider(),
        );
      } catch (e) {
        throw Exception('Google Sign-In failed on Web: $e');
      }
    }

    // Mobile: Use GoogleSignIn plugin with authenticate()
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: DefaultFirebaseOptions
          .currentPlatform
          .androidClientId
    );

    try {
      final GoogleSignInAccount? googleUser =
          await googleSignIn.authenticate();

      if (googleUser == null) {
        throw NoGoogleAccountChosenException();
      }

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance
          .signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // Handling cancellation properly
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw NoGoogleAccountChosenException();
      }
      throw Exception(
        'Google Sign-In failed: ${e.code} - ${e.description}',
      );
    } catch (e) {
      throw Exception(
        'Unexpected error during Google Sign-In: $e',
      );
    }
  }

  static Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'user-disabled') {
        // User might have been deleted/disabled by admin
        // Force logout to clean up state
        await logout();
        throw FirebaseAuthException(
          code: e.code,
          message:
              'Your account has been invalid. Please login again.',
        );
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to reload user: $e');
    }
  }

  static Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Password reset failed',
      );
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  static Future<void> logout() async {
    try {
      if (kIsWeb) {
        // On web, just sign out of Firebase.
        // GoogleSignIn.disconnect() or signOut() on web might be tricky depending on strictness
        // but FirebaseAuth signOut is the primary action.
        await _auth.signOut();
      } else {
        // Mobile
        await GoogleSignIn.instance.signOut();
        await _auth.signOut();
      }
    } catch (e) {
      // Even if one fails, try to force local sign out state if possible
      // But rethrow so UI knows something went wrong (optional)
      throw Exception('Logout failed: $e');
    }
  }
}

class NoGoogleAccountChosenException implements Exception {
  @override
  String toString() => 'No Google account chosen';
}
