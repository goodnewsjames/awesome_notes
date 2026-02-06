import 'package:awesome_notes/change_notifiers/registration_controller.dart';
import 'package:awesome_notes/core/constants.dart';
import 'package:awesome_notes/core/utils/validator.dart';
import 'package:awesome_notes/pages/recover_password_page.dart';
import 'package:awesome_notes/services/auth_service.dart';
import 'package:awesome_notes/services/sync_service.dart';
import 'package:awesome_notes/widgets/note_button.dart';
import 'package:awesome_notes/widgets/note_form_field.dart';
import 'package:awesome_notes/widgets/note_icon_button.dart';
import 'package:awesome_notes/widgets/note_icon_button_outlined.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() =>
      _RegistrationPageState();
}

class _RegistrationPageState
    extends State<RegistrationPage> {
  late final RegistrationController registrationController;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    registrationController = context.read();

    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    formKey = GlobalKey();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Selector<RegistrationController, bool>(
                selector: (_, controller) =>
                    controller.isRegisterMode,
                builder: (_, isRegisterMode, _) => Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        isRegisterMode
                            ? "Register"
                            : "Sign In",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 48,
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "In order to sync your notes to the cloud, you have to register/sign in to the app",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48),
                      if (isRegisterMode) ...[
                        NoteFormField(
                          labelText: "Full name",
                          fillColor: white,
                          controller: nameController,
                          textCapitalization:
                              TextCapitalization.sentences,
                          filled: true,
                          textInputAction:
                              TextInputAction.next,
                          validator:
                              Validator.nameValidator,
                          onChanged: (newValue) {
                            registrationController
                                    .fullName =
                                newValue;
                          },
                        ),
                        SizedBox(height: 8),
                      ],
                      NoteFormField(
                        controller: emailController,
                        labelText: "Email address",
                        keyboardType:
                            TextInputType.emailAddress,
                        fillColor: white,
                        filled: true,
                        textInputAction:
                            TextInputAction.next,
                        validator: Validator.emailValidator,
                        onChanged: (newValue) {
                          registrationController.email =
                              newValue;
                        },
                      ),
                      SizedBox(height: 8),
                      Selector<
                        RegistrationController,
                        bool
                      >(
                        selector: (_, controller) =>
                            controller.isPasswordHidden,
                        builder: (_, isPasswordHidden, _) =>
                            NoteFormField(
                              controller:
                                  passwordController,
                              labelText: "Password",
                              fillColor: white,
                              filled: true,
                              obscureText: isPasswordHidden,
                              suffixIcon: NoteIconButton(
                                icon: isPasswordHidden
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons
                                          .eyeSlash,
                                onPressed: () {
                                  registrationController
                                          .isPasswordHidden =
                                      !isPasswordHidden;
                                },
                              ),
                              validator: Validator
                                  .passwordValidator,
                              onChanged: (newValue) {
                                registrationController
                                        .password =
                                    newValue;
                              },
                            ),
                      ),
                      SizedBox(height: 12),
                      if (!isRegisterMode) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecoverPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Forget password",
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                      SizedBox(
                        height: 48,
                        child: Selector<RegistrationController, bool>(
                          selector:
                              (_, registrationController) =>
                                  registrationController
                                      .isLoading,
                          builder: (_, isLoading, _) => NoteButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (formKey.currentState
                                            ?.validate() ??
                                        false) {
                                      registrationController
                                          .authenticateWithEmailAndPassword(
                                            context,
                                          );

                                      if (AuthService
                                              .isAuthenticated ||
                                          FirebaseAuth
                                                  .instance
                                                  .currentUser !=
                                              null) {
                                        final syncService =
                                            Provider.of<
                                              SyncService
                                            >(
                                              context,
                                              listen: false,
                                            );
                                        syncService
                                            .onLogin();
                                      }
                                    }
                                  },
                            child: isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                          color: white,
                                        ),
                                  )
                                : Text(
                                    isRegisterMode
                                        ? "create my account"
                                        : "Log me in",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Text(
                              isRegisterMode
                                  ? "Or register with"
                                  : "Or sign in with",
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: NoteIconButtonOutlined(
                              icon: FontAwesomeIcons.google,
                              onPressed: () async{
                                registrationController
                                    .authenticateWithGoogle(
                                      context: context,
                                    );
                                     if (AuthService
                                        .isAuthenticated ||
                                    FirebaseAuth
                                            .instance
                                            .currentUser !=
                                        null) {
                                  final syncService =
                                      Provider.of<
                                        SyncService
                                      >(
                                        context,
                                        listen: false,
                                      );
                                  syncService.onLogin();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 32),

                          Expanded(
                            child: NoteIconButtonOutlined(
                              icon:
                                  FontAwesomeIcons.facebook,
                              onPressed: () {
                                registrationController
                                    .authenticateWithFacebook(
                                      context: context,
                                    );
                                     if (AuthService
                                        .isAuthenticated ||
                                    FirebaseAuth
                                            .instance
                                            .currentUser !=
                                        null) {
                                  final syncService =
                                      Provider.of<
                                        SyncService
                                      >(
                                        context,
                                        listen: false,
                                      );
                                  syncService.onLogin();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          style: TextStyle(color: grey700),
                          text: isRegisterMode
                              ? "Already have an account?  "
                              : "Don't have an account?",
                          children: [
                            TextSpan(
                              text: isRegisterMode
                                  ? "Sign in"
                                  : "Register",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      registrationController
                                              .isRegisterMode =
                                          !isRegisterMode;
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
