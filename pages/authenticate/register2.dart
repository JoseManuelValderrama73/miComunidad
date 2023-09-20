import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/services/auth.dart';
import 'package:mi_comunidad/shared/constants.dart';

class Register2 extends StatefulWidget {
  const Register2({Key? key}) : super(key: key);

  @override
  State<Register2> createState() => _Register2State();
}

class _Register2State extends State<Register2> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  Map data = {};

  // text field state
  String name = '';
  String floor = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
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
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF344B6A)),
                    label: const Text('Volver',
                        style: TextStyle(color: Color(0xFF344B6A))),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/wrapper');
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
                                      hintText: 'Nombre'),
                                  validator: (val) => val!.isEmpty
                                      ? 'Introduce un nombre'
                                      : null,
                                  onChanged: (val) {
                                    setState(() {
                                      name = val;
                                    });
                                  }),
                              const SizedBox(height: 20),
                              SingleChildScrollView(
                                child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: 'Piso'),
                                    validator: (val) => val!.isEmpty
                                        ? 'Introduce un piso'
                                        : null,
                                    onChanged: (val) {
                                      setState(() {
                                        floor = val;
                                      });
                                    }),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF344B6A)),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => loading = true);
                                      dynamic result =
                                          await _auth.registerWithEmailAndPwd(
                                              data['email'],
                                              data['pwd'],
                                              name,
                                              floor);
                                      if (result == null) {
                                        setState(() {
                                          error =
                                              'Registrese con un email válido';
                                          loading = false;
                                        });
                                      } else {
                                        Navigator.pushReplacementNamed(
                                            context, '/wrapper');
                                      }
                                    }
                                  },
                                  child: const Text('Registrarse',
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
