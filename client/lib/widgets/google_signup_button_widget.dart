import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:client/provider/google_sign_in.dart';
import 'package:provider/provider.dart';

class GoogleSignupButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          onPrimary: Colors.black,
          minimumSize: Size(double.infinity, 50),
          shape: StadiumBorder(),
        ),
        icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
        label: Text(
          'Sign up with Google',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onPressed: () {
          final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
          provider.googleLogin();
        },
      ),
    );
  }
}