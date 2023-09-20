import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    print(1);
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print(2);
    Navigator.pushReplacementNamed(context, '/wrapper');
    /* Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, '/wrapper');
    }); */
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        height: 150,
        width: 150,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            image: DecorationImage(
                image: AssetImage('assets/icono.jpeg'), fit: BoxFit.fill),
          ),
        ),
      ),
    ));
  }
}
