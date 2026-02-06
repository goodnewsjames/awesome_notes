import 'package:awesome_notes/change_notifiers/registration_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;

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
    // Initialize GoogleSignIn (assumes initialized elsewhere with scopes)
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    try {
      googleSignIn.initialize(
        serverClientId:
            "604946397765-v1sfjcm9f2jfhlnk4f3cnuto4vusm778.apps.googleusercontent.com",
      );
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      return await FirebaseAuth.instance
          .signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
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

  static Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth
        .instance
        .login();

    // Check login result
    if (loginResult.accessToken != null) {
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(
            loginResult.accessToken!.tokenString,
          );

      return await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
    } else {
      // Throw an error or handle gracefully
      throw FirebaseAuthException(
        code: 'ERROR_FACEBOOK_LOGIN_FAILED',
        message:
            loginResult.message ??
            'Facebook login failed or was cancelled',
      );
    }
  }

  static Future<void> resetPassword({
    required String email,
  }) => _auth.sendPasswordResetEmail(email: email);

  static Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
