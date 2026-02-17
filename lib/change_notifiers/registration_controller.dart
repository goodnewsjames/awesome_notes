import 'package:awesome_notes/change_notifiers/notes_provider.dart';
import 'package:awesome_notes/change_notifiers/trash_controller.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/core/dialogs.dart';
import 'package:awesome_notes/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationController extends ChangeNotifier {
  bool _isRegisterMode = true;
  bool get isRegisterMode => _isRegisterMode;
  set isRegisterMode(bool value) {
    _isRegisterMode = value;
    notifyListeners();
  }

  bool _isPasswordHidden = true;
  bool get isPasswordHidden => _isPasswordHidden;

  set isPasswordHidden(bool value) {
    _isPasswordHidden = value;
    notifyListeners();
  }

  String _fullName = "";
  set fullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  String get fullName => _fullName.trim();

  String _email = "";
  set email(String value) {
    _email = value;
    notifyListeners();
  }

  String get email => _email.trim();

  String _password = "";
  set password(String value) {
    _password = value;
    notifyListeners();
  }

  String get password => _password;

  bool _isLoading = false;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  Future<void> _clearLocalData(BuildContext context) async {
    final notesProvider = context.read<NotesProvider>();
    final trashController = context.read<TrashController>();
    await notesProvider.clearAllNotes();
    trashController.clearTrash();
  }

  Future<void> authenticateWithEmailAndPassword(
    BuildContext context,
  ) async {
    isLoading = true;
    try {
      await _clearLocalData(context);
      if (_isRegisterMode) {
        await AuthService.register(
          fullName: fullName,
          email: email,
          password: password,
        );
        if (!context.mounted) return;
        isLoading = false;
        await showMessageDialog(
          context: context,
          message:
              "A verification email was sent to the provided email address. Please confirm your email to proceed to the app.",
        );
        isLoading = true;
        while (!AuthService.isEmailVerified) {
          await Future.delayed(
            Duration(seconds: 5),
            () => AuthService.user?.reload(),
          );
        }
      } else {
        await AuthService.login(
          email: email,
          password: password,
        );
        if (!AuthService.isEmailVerified) {
          if (!context.mounted) return;
          isLoading = false;
          await showMessageDialog(
            context: context,
            message:
                "Your email is not verified yet. A verification email was sent during registration. Please verify to proceed.",
          );
          isLoading = true;
          while (!AuthService.isEmailVerified) {
            await Future.delayed(
              Duration(seconds: 5),
              () => AuthService.user?.reload(),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      showMessageDialog(
        context: context,
        message:
            authExceptionMapper[e.code] ??
            "An unknown error occured!",
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: "An unknown error occured!",
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> authenticateWithGoogle({
    required BuildContext context,
  }) async {
    isLoading = true;
    try {
      await _clearLocalData(context);
      await AuthService.signInWithGoogle();
    } on NoGoogleAccountChosenException {
      return;
    } catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: e.toString(),
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    isLoading = true;
    try {
      await AuthService.resetPassword(email: email);
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message:
            "A reset password link has been sent to $email. Open the link to reset your password",
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      showMessageDialog(
        context: context,
        message:
            authExceptionMapper[e.code] ??
            "An unknown error occured!",
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: "An unknown error occured!",
      );
    } finally {
      isLoading = false;
    }
  }
}

class NoGoogleAccountChosenException implements Exception {
  const NoGoogleAccountChosenException();
}
