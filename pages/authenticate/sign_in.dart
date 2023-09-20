import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/services/auth.dart';
import 'package:mi_comunidad/shared/constants.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String pwd = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingSpin()
        : Scaffold(
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            backgroundColor: backgroundColor,
            appBar: AppBar(
              toolbarHeight: 80,
              title: const Text('Iniciar sesión',
                  style: TextStyle(fontSize: 32, color: Colors.white)),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                TextButton.icon(
                    icon: const Icon(Icons.person, color: Color(0xFF344B6A)),
                    label: const Text('Registrarse',
                        style: TextStyle(color: Color(0xFF344B6A))),
                    onPressed: () {
                      widget.toggleView();
                    })
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/fondo.png'), fit: BoxFit.fill),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[850]!.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                      hintText: 'Email'),
                                  validator: (val) => val!.isEmpty
                                      ? 'Introduce un email'
                                      : null,
                                  onChanged: (val) {
                                    setState(() {
                                      email = val;
                                    });
                                  }),
                              const SizedBox(height: 20),
                              TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                      hintText: 'Contraseña'),
                                  obscureText: true,
                                  onChanged: (val) {
                                    setState(() {
                                      pwd = val;
                                    });
                                  }),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF344B6A)),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => loading = true);

                                      dynamic result = await _auth
                                          .signInWithEmailAndPwd(email, pwd);
                                      if (result == null) {
                                        setState(() {
                                          error =
                                              'No se pudo iniciar sesión con esos credenciales';
                                          loading = false;
                                        });
                                      } else {
                                        Navigator.pushReplacementNamed(
                                            context, '/wrapper');
                                      }
                                    }
                                  },
                                  child: const Text('Iniciar sesión',
                                      style: TextStyle(color: Colors.white))),
                              const SizedBox(height: 12),
                              Text(error,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14)),
                            ],
                          ))),
                ),
              ),
            ));
  }
}
