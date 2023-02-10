import 'package:client/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:client/services/auth_service.dart';

class SignInForm extends StatefulWidget {
  final bool register;

  const SignInForm(this.register, {Key? key}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  // Field values
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ..._buildErrorField(),
          ..._buildNameField(),
          _buildEmailAddressField(),
          const SizedBox(height: 20.0),
          _buildPasswordField(),
          const SizedBox(height: 40.0),
          _buildSignUpButton(),
          _buildGoogleSignInButton(),
        ],
      ),
    );
  }

  List<Widget> _buildErrorField() {
    if (error.isNotEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red.shade100,
            border: Border.all(color: Colors.red.shade900),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(error,
                  style: TextStyle(
                    color: Colors.red.shade900,
                  )),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red.shade900,
                onPressed: () {
                  _setError(null);
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 30.0),
      ];
    }

    return [
      const SizedBox(height: 20.0),
    ];
  }

  List<Widget> _buildNameField() {
    return (widget.register)
        ? [
            TextFormField(
              controller: name,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                filled: true,
                labelText: 'Full Name',
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100))),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                return (value == null || value.isEmpty) ? '' : null;
              },
            ),
            const SizedBox(height: 20.0),
          ]
        : [];
  }

  Widget _buildEmailAddressField() {
    return TextFormField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        filled: true,
        labelText: 'Email Address',
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        prefixIcon: const Icon(Icons.email),
      ),
      validator: (value) {
        return (value == null || value.isEmpty) ? '' : null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: password,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        filled: true,
        labelText: 'Password',
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        prefixIcon: const Icon(Icons.lock),
      ),
      validator: (value) {
        return (value == null || value.length < 6) ? '' : null;
      },
    );
  }

  Widget _buildSignUpButton() {
    String label = widget.register ? 'Create Account' : 'Login';

    return RoundButton(
      onPressed: () async {
        if (_formKey.currentState != null &&
            _formKey.currentState!.validate()) {
          final provider = Provider.of<AuthService>(context, listen: false);

          if (widget.register) {
            provider.registerWithEmailAndPassword(
                name.text, email.text, password.text,
                setError: _setError);
          } else {
            provider.signInWithEmailAndPassword(email.text, password.text,
                setError: _setError);
          }
        }
      },
      text: label,
    );
  }

  Widget _buildGoogleSignInButton() {
    return (widget.register)
        ? const SizedBox(height: 125.0)
        : Column(
            children: [
              const SizedBox(height: 25.0),
              Row(children: [
                Expanded(child: Divider(color: Colors.black.withOpacity(0.5))),
                Text('   or   ',
                    style: TextStyle(color: Colors.black.withOpacity(0.5))),
                Expanded(child: Divider(color: Colors.black.withOpacity(0.5))),
              ]),
              const SizedBox(height: 25.0),
              RoundButton(
                onPressed: () {
                  final provider =
                      Provider.of<AuthService>(context, listen: false);
                  provider.signInWithGoogle();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.google,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Login with Google',
                      style: Theme.of(context).textTheme.headline2!.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                  ],
                ),
              )
            ],
          );
  }

  void _setError(String? errorMessage) =>
      setState(() => error = errorMessage ?? '');
}
