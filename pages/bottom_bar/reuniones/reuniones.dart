import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_comunidad/shared/constants.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:mi_comunidad/pages/bottom_bar/reuniones/new_reuniones_panel.dart';

class ReunionesPage extends StatefulWidget {
  const ReunionesPage(
      {Key? key, required this.userCommunity, required this.admin})
      : super(key: key);
  final String userCommunity;
  final bool admin;

  @override
  _ReunionesPageState createState() => _ReunionesPageState();
}

class _ReunionesPageState extends State<ReunionesPage> {
  List<String> reuniones = [];

  Future removeItem(reunion) async {
    reuniones.removeWhere((element) => element == reunion);
    setState(() {});
  }

  void _newReunionesPanel() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            NewReunionesPanel(community: widget.userCommunity));
  }

  @override
  Widget build(BuildContext context) {
    Future getReuniones(CollectionReference collection) async {
      await collection.get().then((snapshot) => snapshot.docs.forEach((doc) {
            if (!reuniones.contains(doc.reference.id)) {
              reuniones.add(doc.reference.id);
            }
          }));
    }

    CollectionReference reunionesCollection = FirebaseFirestore.instance
        .collection('communities/${widget.userCommunity}/reuniones');
    return FutureBuilder(
        future: getReuniones(reunionesCollection),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: backgroundColor,
            floatingActionButton: Visibility(
              visible: widget.admin,
              child: FloatingActionButton(
                  heroTag: "btn1",
                  backgroundColor: const Color(0xFFEE9E83),
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    _newReunionesPanel();
                  }),
            ),
            body: RefreshIndicator(
              color: const Color(0xFFEE9E83),
              onRefresh: () async {
                return setState(() {});
              },
              child: ListView.builder(
                  itemCount: reuniones.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                        future: reunionesCollection.doc(reuniones[index]).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data!.data() != null) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              if (widget.admin) {
                                return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 7),
                                    child: Slidable(
                                      endActionPane: ActionPane(
                                          extentRatio: 0.4,
                                          motion: const ScrollMotion(),
                                          children: <Widget>[
                                            SlidableAction(
                                                borderRadius:
                                                    slidableBorderRadius,
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
                                                                    '¿Quieres borrar la reunión "${data['description']}"?'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Cancelar'),
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                  ),
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Eliminar'),
                                                                    onPressed:
                                                                        () async {
                                                                      await DatabaseService(communityName: widget.userCommunity)
                                                                          .deleteReuniones(
                                                                              reuniones[index]);
                                                                      await removeItem(
                                                                          reuniones[
                                                                              index]);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  )
                                                                ],
                                                              ));
                                                })
                                          ]),
                                      child: Card(
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 0, 20, 0),
                                        child: ListTile(
                                          title: Text(data['description']),
                                          subtitle: Text(data['date']),
                                        ),
                                      ),
                                    ));
                              } else {
                                return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Card(
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 6, 20, 0),
                                        child: ListTile(
                                          title: Text(data['description']),
                                          subtitle: Text(data['date']),
                                        )));
                              }
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
