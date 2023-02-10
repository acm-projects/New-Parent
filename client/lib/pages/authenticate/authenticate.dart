import 'package:flutter/material.dart';

import 'package:client/pages/authenticate/signin_form.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool register = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraint.maxHeight - 30,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 25.0),
                    _buildTitle(),
                    const SizedBox(height: 30.0),
                    SignInForm(register),
                    _buildToggle()
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    String title = register ? 'Create a new account' : 'Welcome to BabyQuest';
    String subtitle =
        register ? 'Sign up to get started:' : 'Sign in to continue:';

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: Theme.of(context).textTheme.headline1),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(subtitle, style: Theme.of(context).textTheme.headline2),
        )
      ],
    );
  }

  Widget _buildToggle() {
    String label =
        register ? 'Already have an account? ' : 'Don\'t have an account? ';
    String buttonLabel = register ? 'Sign In' : 'Register Now';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16.0,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => setState(() => register = !register),
              child: Text(buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
