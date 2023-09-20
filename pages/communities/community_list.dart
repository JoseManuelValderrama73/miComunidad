import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:provider/provider.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/pages/communities/community_tile.dart';
import 'package:mi_comunidad/pages/communities/new_community_pannel.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../Shared/constants.dart';

class CommunityList extends StatefulWidget {
  const CommunityList({Key? key, required this.previousCommunity})
      : super(key: key);
  final String previousCommunity;

  @override
  _CommunityListState createState() => _CommunityListState();
}

class _CommunityListState extends State<CommunityList> {
  final fieldText = TextEditingController();
  List<String> communities = [];
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future removeItem(item) async {
    communities.removeWhere((element) => element == item);
    setState(() {});
  }

  void clearText() {
    fieldText.clear();
  }

  void _newCommunityPanel(uid, previousCommunity) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => NewCommunityPanel(
            uid: uid,
            previousCommunity: previousCommunity,
            communities: communities));
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = <String>[];
    dummySearchList.addAll(communities);
    if (query.isNotEmpty) {
      List<String> dummyListData = <String>[];
      for (var item in dummySearchList) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      }
      setState(() {
        communities.clear();
        communities.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        communities.clear();
        communities.addAll(communities);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future getCommunities() async {
      await FirebaseFirestore.instance
          .collection('communities')
          .get()
          .then((snapshot) => snapshot.docs.forEach((doc) {
                if (!communities.contains(doc.reference.id)) {
                  communities.add(doc.reference.id);
                }
              }));
    }

    final user = Provider.of<NewUser?>(context);
    return user == null
        ? const LoadingSpin()
        : Scaffold(
            floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFFEE9E83),
                child: const Icon(Icons.add),
                onPressed: () async {
                  _newCommunityPanel(user.uid, widget.previousCommunity);
                }),
            body: Column(
              children: [
                TextField(
                  controller: fieldText,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Buscar comunidad',
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF344B6A)),
                      suffixIcon: IconButton(
                          color: const Color(0xFF344B6A),
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            fieldText.text.isNotEmpty
                                ? clearText()
                                : FocusScope.of(context).unfocus();
                          })),
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                ),
                Flexible(
                  child: FutureBuilder(
                      future: getCommunities(),
                      builder: (context, snapshot) {
                        return FutureBuilder<DocumentSnapshot>(
                            future: usersCollection.doc(user.uid).get(),
                            builder: (context, communitySnapshot) {
                              if (communitySnapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic> data =
                                    communitySnapshot.data!.data()
                                        as Map<String, dynamic>;
                                return RefreshIndicator(
                                  color: const Color(0xFFEE9E83),
                                  onRefresh: () async {
                                    return setState(() {});
                                  },
                                  child: ListView.builder(
                                      itemCount: communities.length,
                                      itemBuilder: (context, index) {
                                        if (data['admin'] &&
                                            data['community'] ==
                                                communities[index]) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Card(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 6, 20, 0),
                                                  child: Slidable(
                                                    endActionPane: ActionPane(
                                                        motion:
                                                            const ScrollMotion(),
                                                        children: <Widget>[
                                                          SlidableAction(
                                                            onPressed: (BuildContext
                                                                context) async {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          AlertDialog(
                                                                            title:
                                                                                Text('¿Quieres borrar la comunidad "${communities[index]}"?'),
                                                                            actions: <Widget>[
                                                                              TextButton(
                                                                                child: const Text('Cancelar'),
                                                                                onPressed: () => Navigator.pop(context),
                                                                              ),
                                                                              TextButton(
                                                                                child: const Text('Eliminar'),
                                                                                onPressed: () async {
                                                                                  await FirebaseFirestore.instance.collection('communities/${data['community']}/reuniones').get().then((snapshot) => snapshot.docs.forEach((doc) {
                                                                                        DatabaseService(communityName: data['community']).deleteReuniones(doc.reference.id);
                                                                                      }));
                                                                                  await FirebaseFirestore.instance.collection('communities/${data['community']}/incidencias').get().then((snapshot) => snapshot.docs.forEach((doc) {
                                                                                        DatabaseService(communityName: data['community']).deleteIncidencias(doc.reference.id);
                                                                                      }));
                                                                                  await FirebaseFirestore.instance.collection('communities/${data['community']}/communityUsers').get().then((snapshot) => snapshot.docs.forEach((doc) {
                                                                                        usersCollection.doc(doc.reference.id).get().then((userSnapshot) {
                                                                                          DatabaseService(uid: doc.reference.id).updateUserData(userSnapshot['name'], userSnapshot['floor'], 'Sin comunidad asignada', false);
                                                                                          DatabaseService(communityName: data['community'], uid: doc.reference.id).updateCommunityUsersData(true);
                                                                                        });
                                                                                      }));
                                                                                  await FirebaseFirestore.instance.collection('communities/${data['community']}/pendingUsers').get().then((snapshot) => snapshot.docs.forEach((doc) {
                                                                                        usersCollection.doc(doc.reference.id).get().then((pendingSnapshot) {
                                                                                          DatabaseService(uid: doc.reference.id).updateUserData(pendingSnapshot['name'], pendingSnapshot['floor'], 'Sin comunidad asignada', false);
                                                                                          DatabaseService(communityName: data['community'], uid: doc.reference.id).updateCommunityPendingUsersData(true);
                                                                                        });
                                                                                      }));
                                                                                  await DatabaseService(communityName: communities[index]).deleteCommunity();
                                                                                  await removeItem(communities[index]);
                                                                                  Navigator.pop(context);
                                                                                },
                                                                              )
                                                                            ],
                                                                          ));
                                                            },
                                                            backgroundColor:
                                                                Colors.red,
                                                            icon: Icons.delete,
                                                          )
                                                        ]),
                                                    child: ListTile(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  const AlertDialog(
                                                                    title:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child: Text(
                                                                          'Ya perteneces a ésta comunidad'),
                                                                    ),
                                                                  ));
                                                        },
                                                        title: CommunityTile(
                                                            community:
                                                                communities[
                                                                    index])),
                                                  )));
                                        } else {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Card(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 6, 20, 0),
                                                  child: ListTile(
                                                      onTap: () {
                                                        if (data['admin']) {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  const AlertDialog(
                                                                      title:
                                                                          Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            8,
                                                                            8,
                                                                            8,
                                                                            0),
                                                                        child: Text(
                                                                            '¡Eres el presidente!'),
                                                                      ),
                                                                      content:
                                                                          Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            8,
                                                                            0,
                                                                            8,
                                                                            8),
                                                                        child: Text(
                                                                            'Cede la presidencia desde la pestaña "Vecinos" o elimina tu comunidad actual para unirte a otra'),
                                                                      )));
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  AlertDialog(
                                                                      title: Text(
                                                                          '¿Quieres unirte a ${communities[index]}?'),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                            child:
                                                                                const Text('Cancelar'),
                                                                            onPressed: () => Navigator.pop(context)),
                                                                        TextButton(
                                                                            child:
                                                                                const Text('0K'),
                                                                            onPressed: () async {
                                                                              await DatabaseService(communityName: widget.previousCommunity, uid: user.uid).updateCommunityUsersData(true);
                                                                              await DatabaseService(communityName: widget.previousCommunity, uid: user.uid).updateCommunityPendingUsersData(true);
                                                                              await DatabaseService(uid: user.uid).updateUserData(data['name'], data['floor'], 'Pendiente de admisión en ${communities[index]}', false);
                                                                              await DatabaseService(communityName: communities[index], uid: user.uid).updateCommunityPendingUsersData(false);
                                                                              Navigator.pop(context);
                                                                            })
                                                                      ]));
                                                        }
                                                      },
                                                      title: CommunityTile(
                                                          community:
                                                              communities[
                                                                  index]))));
                                        }
                                      }),
                                );
                              } else {
                                return const LoadingSpin();
                              }
                            });
                      }),
                ),
              ],
            ),
          );
  }
}
