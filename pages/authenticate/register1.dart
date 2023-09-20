import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/shared/constants.dart';

class Register extends StatefulWidget {
  const Register({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String pwd = '';
  String securityPwd = '';
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
              title: const Text('Registrarse',
                  style: TextStyle(fontSize: 32, color: Colors.white)),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                TextButton.icon(
                    icon: const Icon(Icons.person, color: Color(0xFF344B6A)),
                    label: const Text('Iniciar sesión',
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
                  reverse: true,
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
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
                                  validator: (val) => val!.length < 6
                                      ? 'Minimo 6 caracteres'
                                      : null,
                                  obscureText: true,
                                  onChanged: (val) {
                                    setState(() {
                                      pwd = val;
                                    });
                                  }),
                              const SizedBox(height: 20),
                              TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                      hintText: 'Contraseña'),
                                  validator: (val) => val!.length < 6
                                      ? 'Minimo 6 caracteres'
                                      : null,
                                  obscureText: true,
                                  onChanged: (val) {
                                    setState(() {
                                      securityPwd = val;
                                    });
                                  }),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF344B6A)),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (pwd == securityPwd) {
                                        Navigator.pushReplacementNamed(
                                            context, '/register2', arguments: {
                                          'email': email,
                                          'pwd': pwd
                                        });
                                      } else {
                                        setState(() {
                                          error =
                                              'Las contraseñas no coinciden';
                                        });
                                      }
                                    }
                                  },
                                  child: const Text('Siguiente',
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
