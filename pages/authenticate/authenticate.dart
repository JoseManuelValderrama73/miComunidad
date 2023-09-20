import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/authenticate/register1.dart';
import 'package:mi_comunidad/pages/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn == true
        ? SignIn(toggleView: toggleView)
        : Register(toggleView: toggleView);
  }
}
