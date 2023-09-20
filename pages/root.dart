import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/bottom_bar/incidencias/incidencias.dart';
import 'package:mi_comunidad/pages/bottom_bar/reuniones/reuniones.dart';
import 'package:mi_comunidad/pages/bottom_bar/vecinos.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Root extends StatefulWidget {
  const Root({Key? key, required this.uid}) : super(key: key);
  final String? uid;

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int selectedIndex = 0;
  final List<String> _pageNames = ['Reuniones', 'Vecinos', 'Incidencias'];
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  late final Future<DocumentSnapshot?> getData =
      usersCollection.doc(widget.uid).get();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
        future: getData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String?, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            List<Widget> pages = [
              ReunionesPage(
                  userCommunity: data['community'], admin: data['admin']),
              Vecinos(
                  userCommunity: data['community'],
                  uid: widget.uid,
                  admin: data['admin'],
                  name: data['name'],
                  floor: data['floor']),
              IncidenciasPage(
                  userCommunity: data['community'], admin: data['admin'])
            ];
            return Scaffold(
              backgroundColor: backgroundColor,
              body: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
              appBar: AppBar(
                  toolbarHeight: 80,
                  title: Text(_pageNames[selectedIndex],
                      style:
                          const TextStyle(fontSize: 32, color: Colors.white)),
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
                        icon: const Icon(Icons.settings,
                            color: Color(0xFF344B6A), size: 28),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/miperfil');
                        })
                  ]),
              bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.table_bar), label: 'Reuniones'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.group), label: 'Vecinos'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.warning), label: 'Incidencias'),
                  ],
                  currentIndex: selectedIndex,
                  unselectedItemColor: Colors.grey[500],
                  selectedItemColor: const Color(0xFFEE9E83),
                  onTap: _onItemTapped),
            );
          }
          return const LoadingSpin();
        });
  }
}
