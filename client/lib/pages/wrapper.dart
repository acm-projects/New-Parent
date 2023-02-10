import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:client/models/app_user.dart';
import 'package:client/pages/authenticate/authenticate.dart';
import 'package:client/pages/main/main_wrapper.dart';
import 'package:client/pages/splash_page.dart';
import 'package:client/services/auth_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool userLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder(
        stream: AuthService.appUserStream,
        builder: _builder,
      ),
    );
  }

  Widget _builder(contest, snapshot) {
    userLoaded = !(AppUser.currentUser == null || !AppUser.currentUser!.isLoaded);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasData && !userLoaded) {
      _waitForUserToLoad();
      return const SplashPage('Welcome...', timed: false);
    } else if (snapshot.hasData && userLoaded) {
      return MainWrapper(_refresh); // main page
    } else if (snapshot.hasError) {
      return const Center(child: Text('Something went wrong!'));
    } else {
      return const Authenticate(); // authentication
    }
  }

  Future _waitForUserToLoad() async {
    await Future.delayed(const Duration(milliseconds: 250), () {
      if (AppUser.currentUser != null && AppUser.currentUser!.isLoaded) {
        setState(() => userLoaded = true);
      } else {
        _waitForUserToLoad();
      }
    });
  }

  void _refresh() => setState(() {});
}
