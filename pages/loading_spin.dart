import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class LoadingSpin extends StatelessWidget {
  const LoadingSpin({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SpinKitRing(color: Color(0xFFEE9E83), size: 50),
        ));
  }
}
