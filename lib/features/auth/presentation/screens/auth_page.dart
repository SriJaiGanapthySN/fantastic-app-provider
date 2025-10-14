//This page determine whether to show the login or the register page

import 'package:flutter/material.dart';

import 'create_account_page.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //initially show login page
  bool showLoginPage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return SignInPage(
        togglePages: togglePages,
      );
    } else {
      return CreateAccountPage(
        togglePages: togglePages,
      );
    }
  }
}
