import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/services/auth.dart';
import 'package:mi_comunidad/shared/constants.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  String _userType = '';
  String? _currentName;
  String? _currentFloor;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<NewUser?>(context);
    return user == null
        ? const LoadingSpin()
        : StreamBuilder<UserDataWithUID>(
            stream: DatabaseService(uid: user.uid).userDataWithUID,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserDataWithUID? userData = snapshot.data;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (userData!.community == 'Sin comunidad asignada' ||
                      userData.community.contains('Pendiente de admisión en')) {
                    setState(() {
                      _userType = '-';
                    });
                  } else {
                    if (userData.admin) {
                      setState(() {
                        _userType = 'Presidente de la comunidad';
                      });
                    } else {
                      setState(() {
                        _userType = 'Vecino de la comunidad';
                      });
                    }
                  }
                });
                return Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: backgroundColor,
                    appBar: AppBar(
                        toolbarHeight: 80,
                        title: Text((userData!.name).toString(),
                            style: const TextStyle(
                                fontSize: 32, color: Colors.white)),
                        centerTitle: false,
                        elevation: 0,
                        flexibleSpace: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/appbar.jpeg'),
                                  fit: BoxFit.fill)),
                        ),
                        actions: <Widget>[
                          IconButton(
                              icon: const Icon(Icons.home,
                                  color: Color(0xFF344B6A), size: 28),
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, '/wrapper')),
                        ]),
                    body: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                              margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(userData.floor,
                                      style: const TextStyle(fontSize: 15)),
                                  Divider(height: 30, color: Colors.grey[600]),
                                  Text(userData.community,
                                      style: const TextStyle(fontSize: 15)),
                                  Divider(height: 30, color: Colors.grey[600]),
                                  Text(_userType,
                                      style: const TextStyle(fontSize: 15))
                                ],
                              )),
                          Container(
                              margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    TextFormField(
                                      initialValue: userData.name,
                                      decoration: textInputDecoration,
                                      validator: (val) {
                                        val!.isEmpty
                                            ? 'Introduzca un nombre'
                                            : null;
                                        return null;
                                      },
                                      onChanged: (val) {
                                        setState(() => _currentName = val);
                                      },
                                    ),
                                    Divider(
                                        height: 30, color: Colors.grey[600]),
                                    TextFormField(
                                      initialValue: userData.floor,
                                      decoration: textInputDecoration,
                                      validator: (val) {
                                        val!.isEmpty
                                            ? 'Introduzca un nombre'
                                            : null;
                                        return null;
                                      },
                                      onChanged: (val) {
                                        setState(() => _currentFloor = val);
                                      },
                                    ),
                                    Divider(
                                        height: 30, color: Colors.grey[600]),
                                    Center(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF344B6A)),
                                          child: const Text(
                                            'Actualizar',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await DatabaseService(
                                                      uid: user.uid)
                                                  .updateUserData(
                                                      _currentName ??
                                                          userData.name,
                                                      _currentFloor ??
                                                          userData.floor,
                                                      userData.community,
                                                      userData.admin);
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                              )),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF344B6A)),
                              child: const Text(
                                'Unirme a una comunidad',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/communities');
                              }),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: Divider(height: 30, color: Colors.grey[600]),
                          ),
                          Visibility(
                            visible: userData.community !=
                                    'Sin comunidad asignada' &&
                                !userData.community
                                    .contains('Pendiente de admisión en'),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Salir de ${userData.community}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  if (!userData.admin) {
                                    await DatabaseService(
                                            uid: user.uid,
                                            communityName: userData.community)
                                        .updateCommunityUsersData(true);
                                    await DatabaseService(uid: user.uid)
                                        .updateUserData(
                                            _currentName ?? userData.name,
                                            _currentFloor ?? userData.floor,
                                            'Sin comunidad asignada',
                                            false);
                                    setState(() => {});
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: const Text(
                                                  '¡Eres el presidente!'),
                                              content: const Text(
                                                  'Cede la presidencia desde la pestaña "Vecinos" o elimina tu comunidad actual para unirte a otra'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('0K'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ));
                                  }
                                }),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Cerrar sesión',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                Navigator.pushReplacementNamed(
                                    context, '/wrapper');
                                await _auth.signOut();
                              }),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                            child: Divider(height: 30, color: Colors.grey[600]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(50),
                            child: Column(
                              children: [
                                const Text(
                                  'Aplicación realizada por',
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
                                  'José Manuel Valderrama Sánchez',
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          icon: FaIcon(
                                              FontAwesomeIcons.instagram,
                                              color: Colors.grey[600]),
                                          onPressed: () {}),
                                      const Text('@josee.valde')
                                    ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              } else {
                return const LoadingSpin();
              }
            });
  }
}
