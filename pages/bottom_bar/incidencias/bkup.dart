import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_comunidad/shared/constants.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:mi_comunidad/pages/bottom_bar/incidencias/new_incidencias_panel.dart';

class IncidenciasPage extends StatefulWidget {
  const IncidenciasPage(
      {Key? key, required this.userCommunity, required this.admin})
      : super(key: key);
  final String userCommunity;
  final bool admin;

  @override
  _IncidenciasPageState createState() => _IncidenciasPageState();
}

class _IncidenciasPageState extends State<IncidenciasPage> {
  List<String> incidencias = [];
  bool done = false;
  Future getIncidencias(CollectionReference collection) async {
    await collection.get().then((snapshot) => snapshot.docs.forEach((doc) {
          if (!incidencias.contains(doc.reference.id)) {
            incidencias.add(doc.reference.id);
          }
        }));
  }

  Future removeItem(incidencia) async {
    incidencias.removeWhere((element) => element == incidencia);
    setState(() {});
  }

  void _newIncidenciasPanel() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            NewIncidenciasPanel(community: widget.userCommunity));
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference incidenciasCollection = FirebaseFirestore.instance
        .collection('communities/${widget.userCommunity}/incidencias');
    return FutureBuilder(
        future: getIncidencias(incidenciasCollection),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: backgroundColor,
            floatingActionButton: Visibility(
              visible:
                  !widget.userCommunity.contains('Pendiente de admisión en') &&
                      widget.userCommunity != 'Sin comunidad asignada',
              child: FloatingActionButton(
                  heroTag: "btn2",
                  backgroundColor: const Color(0xFFEE9E83),
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    _newIncidenciasPanel();
                  }),
            ),
            body: RefreshIndicator(
              color: const Color(0xFFEE9E83),
              onRefresh: () async {
                return setState(() {});
              },
              child: ListView.builder(
                  itemCount: incidencias.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                        future:
                            incidenciasCollection.doc(incidencias[index]).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data!.data() != null) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              done = data['done'];
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Card(
                                      margin: const EdgeInsets.fromLTRB(
                                          20, 6, 20, 0),
                                      child: Slidable(
                                        endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: <Widget>[
                                              SlidableAction(
                                                  backgroundColor: Colors.red,
                                                  icon: Icons.delete,
                                                  onPressed: (BuildContext
                                                      context) async {
                                                    showDialog(
                                                        context: context,
                                                        builder:
                                                            (context) =>
                                                                AlertDialog(
                                                                  title: Text(
                                                                      '¿Quieres borrar ésta incidencia?'),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      child: const Text(
                                                                          'Cancelar'),
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                    ),
                                                                    TextButton(
                                                                      child: const Text(
                                                                          'Eliminar'),
                                                                      onPressed:
                                                                          () async {
                                                                        await DatabaseService(communityName: widget.userCommunity)
                                                                            .deleteIncidencias(incidencias[index]);
                                                                        await removeItem(
                                                                            incidencias[index]);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    )
                                                                  ],
                                                                ));
                                                  })
                                            ]),
                                        child: CheckboxListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Text(data['name']),
                                            ),
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            value: data['done'],
                                            activeColor:
                                                const Color(0xFFEE9E83),
                                            onChanged: (val) {
                                              setState(() => done = !done);
                                              DatabaseService(
                                                      communityName:
                                                          widget.userCommunity)
                                                  .updateIncidenciasData(
                                                      data['name'],
                                                      !data['done']);
                                            }),
                                      )));
                            }
                            return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Card(
                                    margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                    child:
                                        ListTile(title: Text('Cargando...'))));
                          }
                          return Container();
                        });
                  }),
            ),
          );
        });
  }
}
