import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/authenticate/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:mi_comunidad/pages/root.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<NewUser?>(context);
    return user == null ? const Authenticate() : Root(uid: user.uid);
  }
}
