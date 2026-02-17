import 'package:awesome_notes/change_notifiers/registration_controller.dart';
import 'package:awesome_notes/core/core.dart';
import 'package:awesome_notes/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() =>
      _RecoverPasswordPageState();
}

class _RecoverPasswordPageState
    extends State<RecoverPasswordPage> {
  late final TextEditingController emailController;
  GlobalKey<FormFieldState> emailKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NoteBackButton(),
        title: Text("Recover Password"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: emailKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Don't worry! Happens to the best of us!",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                NoteFormField(
                  controller: emailController,
                  key: emailKey,
                  fillColor: white,
                  filled: true,
                  labelText: "Email",
                  validator: Validator.emailValidator,
                ),
                SizedBox(height: 24),
            
                SizedBox(
                  height: 48,
                  child: Selector<RegistrationController, bool>(
                    selector: (_, controller) =>
                        controller.isLoading,
                    builder: (_, isLoading, _) => NoteButton(
                      onPressed: isLoading? null:() {
                        if (emailKey.currentState
                                ?.validate() ??
                            false) {
                          context
                              .read<RegistrationController>()
                              .resetPassword(
                                context: context,
                                email: emailController.text
                                    .trim(),
                              );
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
                          : Text("Send me a recovery link!"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
