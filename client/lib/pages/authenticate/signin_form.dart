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
  String name = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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

  Widget _buildEmailAddressField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        return (value == null || value.isEmpty)
            ? 'Enter an email adress'
            : null;
      },
      onChanged: (value) => setState(() => email = value),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        prefixIcon: Icon(Icons.lock),
      ),
      validator: (value) {
        return (value == null || value.length < 6)
            ? 'Password must be at least 6 characters long'
            : null;
      },
      onChanged: (value) => setState(() => password = value),
    );
  }

  Widget _buildSignUpButton() {
    String label = widget.register ? 'Create Account' : 'Login';

    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
      ),
      child: MaterialButton(
        onPressed: () async {
          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            final provider = Provider.of<AuthService>(context, listen: false);

            if (widget.register) {
              provider.registerWithEmailAndPassword(email, password);
            } else {
              provider.signInWithEmailAndPassword(email, password);
            }
          }
        },
        color: Colors.green.shade200,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),

      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    if (widget.register) {
      return const SizedBox(height: 125.0);
    } else {
      return Column(
        children: [
          const SizedBox(height: 25.0),
          Row(children: [
            Expanded(child: Divider(color: Colors.black.withOpacity(0.5))),
            Text('   or   ',
                style: TextStyle(color: Colors.black.withOpacity(0.5))),
            Expanded(child: Divider(color: Colors.black.withOpacity(0.5))),
          ]),
          const SizedBox(height: 25.0),
          Container(
            padding: const EdgeInsets.all(4),
            child: ElevatedButton.icon(
              onPressed: () {
                final provider =
                Provider.of<AuthService>(context, listen: false);
                provider.signInWithGoogle();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green.shade200,
                onPrimary: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: const StadiumBorder(),
              ),
              icon: FaIcon(FontAwesomeIcons.google, color: Colors.deepPurple.shade400),
              label: const Text(
                'Login with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}