import 'package:flutter/material.dart';
import 'package:mi_comunidad/Shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/services/database.dart';

class NewCommunityPanel extends StatefulWidget {
  const NewCommunityPanel(
      {Key? key,
      required this.uid,
      required this.previousCommunity,
      required this.communities})
      : super(key: key);
  final String uid;
  final String previousCommunity;
  final List communities;

  @override
  State<NewCommunityPanel> createState() => _NewCommunityPanelState();
}

class _NewCommunityPanelState extends State<NewCommunityPanel> {
  final _formKey = GlobalKey<FormState>();

  String? _currentName;
  String? _currentAdress;
  String _error = '';
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  late final Future<DocumentSnapshot>? getDoc =
      usersCollection.doc(widget.uid).get();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: getDoc,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Form(
              key: _formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('Introduce los datos de la comunidad',
                            style: TextStyle(fontSize: 18))),
                    const SizedBox(height: 20),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(children: <Widget>[
                          TextFormField(
                            autofocus: true,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Nombre'),
                            validator: (val) =>
                                val!.isEmpty ? 'Introduce un nombre' : null,
                            onChanged: (val) {
                              setState(() => _currentName = val);
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            autofocus: true,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Dirección'),
                            validator: (val) =>
                                val!.isEmpty ? 'Introduce una dirección' : null,
                            onChanged: (val) {
                              setState(() => _currentAdress = val);
                            },
                          ),
                        ])),
                    const SizedBox(height: 20),
                    Text(_error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF344B6A)),
                        child: const Text('Crear',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (data['admin']) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title:
                                            const Text('¡Eres el presidente!'),
                                        content: const Text(
                                            'Primero debes nombrar a otro presidente desde la pantalla "Vecinos"'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('0K'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      ));
                            } else {
                              if (!widget.communities.contains(_currentName)) {
                                await DatabaseService().updateCommunityData(
                                    _currentName, _currentAdress);
                                await DatabaseService(uid: widget.uid)
                                    .updateUserData(data['name'], data['floor'],
                                        _currentName, true);
                                await DatabaseService(
                                        communityName: widget.previousCommunity
                                            .replaceAll(
                                                'Pendiente de admisión en ',
                                                ''),
                                        uid: widget.uid)
                                    .updateCommunityUsersData(true);
                                await DatabaseService(
                                        communityName: widget.previousCommunity
                                            .replaceAll(
                                                'Pendiente de admisión en ',
                                                ''),
                                        uid: widget.uid)
                                    .updateCommunityPendingUsersData(true);
                                await DatabaseService(
                                        uid: widget.uid,
                                        communityName: _currentName)
                                    .updateCommunityUsersData(false);
                                Navigator.pop(context);
                              } else {
                                setState(() => _error =
                                    'Ya existe una comunidad con ese nombre');
                              }
                            }
                          }
                        }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          }
          return const LoadingSpin();
        }));
  }
}
