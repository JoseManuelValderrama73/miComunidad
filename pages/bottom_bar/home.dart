import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/bottom_bar/reuniones/reuniones.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.userCommunity, required this.admin})
      : super(key: key);
  final String userCommunity;
  final bool admin;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ReunionesPage(
        userCommunity: widget.userCommunity, admin: widget.admin);
  }
}
