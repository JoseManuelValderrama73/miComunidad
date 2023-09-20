import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mi_comunidad/shared/constants.dart';

class Vecinos extends StatefulWidget {
  const Vecinos({
    Key? key,
    required this.userCommunity,
    required this.uid,
    required this.admin,
    required this.name,
    required this.floor,
  }) : super(key: key);
  final String userCommunity;
  final String floor;
  final String name;
  final String? uid;
  final bool admin;

  @override
  _VecinosState createState() => _VecinosState();
}

class _VecinosState extends State<Vecinos> {
  List<String> vecinos = [];
  List<String> pendingVecinos = [];
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future removeItem(vecino, list) async {
    list.removeWhere((element) => element == vecino);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference vecinosCollection = FirebaseFirestore.instance
        .collection('communities/${widget.userCommunity}/communityUsers');
    CollectionReference pendingVecinosCollection = FirebaseFirestore.instance
        .collection('communities/${widget.userCommunity}/pendingUsers');
    Future getVecinos() async {
      await vecinosCollection
          .get()
          .then((snapshot) => snapshot.docs.forEach((doc) {
                if (!vecinos.contains(doc.reference.id)) {
                  vecinos.add(doc.reference.id);
                }
              }));
    }

    Future getPendingVecinos() async {
      await pendingVecinosCollection
          .get()
          .then((snapshot) => snapshot.docs.forEach((doc) {
                if (!pendingVecinos.contains(doc.reference.id)) {
                  pendingVecinos.add(doc.reference.id);
                }
              }));
    }

    return RefreshIndicator(
      color: const Color(0xFFEE9E83),
      onRefresh: () async {
        return setState(() {});
      },
      child: ListView(
        children: <Widget>[
          Visibility(
            visible: widget.admin,
            child: FutureBuilder(
                future: getPendingVecinos(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: pendingVecinos.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                          future: pendingVecinosCollection
                              .doc(pendingVecinos[index])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data!.data() != null) {
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return FutureBuilder<DocumentSnapshot>(
                                    future:
                                        usersCollection.doc(data['uid']).get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.done) {
                                        Map<String, dynamic> userData =
                                            userSnapshot.data!.data()
                                                as Map<String, dynamic>;
                                        return Card(
                                            margin: const EdgeInsets.fromLTRB(
                                                20, 16, 20, 0),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ListTile(
                                                  title: Text(
                                                      '${userData['name']} - ${userData['floor']}',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                  subtitle: Row(
                                                    children: <Widget>[
                                                      TextButton(
                                                          child: const Text(
                                                              'Aceptar'),
                                                          onPressed: () async {
                                                            await DatabaseService(
                                                                    uid: data[
                                                                        'uid'])
                                                                .updateUserData(
                                                                    userData[
                                                                        'name'],
                                                                    userData[
                                                                        'floor'],
                                                                    widget
                                                                        .userCommunity,
                                                                    false);
                                                            await DatabaseService(
                                                                    uid: data[
                                                                        'uid'],
                                                                    communityName:
                                                                        widget
                                                                            .userCommunity)
                                                                .updateCommunityPendingUsersData(
                                                                    true);
                                                            await DatabaseService(
                                                                    uid: data[
                                                                        'uid'],
                                                                    communityName:
                                                                        widget
                                                                            .userCommunity)
                                                                .updateCommunityUsersData(
                                                                    false);
                                                            removeItem(
                                                                pendingVecinos[
                                                                    index],
                                                                pendingVecinos);
                                                          }),
                                                      TextButton(
                                                          child: const Text(
                                                              'Rechazar'),
                                                          onPressed: () async {
                                                            await DatabaseService(
                                                                    uid: data[
                                                                        'uid'])
                                                                .updateUserData(
                                                                    userData[
                                                                        'name'],
                                                                    userData[
                                                                        'floor'],
                                                                    'Sin comunidad asignada',
                                                                    false);
                                                            await DatabaseService(
                                                                    uid: data[
                                                                        'uid'],
                                                                    communityName:
                                                                        widget
                                                                            .userCommunity)
                                                                .updateCommunityPendingUsersData(
                                                                    true);
                                                            await removeItem(
                                                                data['uid'],
                                                                pendingVecinos);
                                                          })
                                                    ],
                                                  )),
                                            ));
                                      } else {
                                        return const Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Card(
                                                margin: EdgeInsets.fromLTRB(
                                                    20, 6, 20, 0),
                                                child: ListTile(
                                                    title: Text(
                                                        'Cargando.....'))));
                                      }
                                    });
                              }
                              return const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Card(
                                      margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                      child: ListTile(
                                          title: Text('Cargando....'))));
                            }
                            return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Card(
                                    margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                    child:
                                        ListTile(title: Text('Cargando...'))));
                          });
                    },
                  );
                }),
          ),
          Visibility(
            visible: pendingVecinos.isNotEmpty,
            child: Divider(
                height: 70, indent: 20, endIndent: 20, color: Colors.grey[600]),
          ),
          FutureBuilder(
              future: getVecinos(),
              builder: (context, snapshot) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: vecinos.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                          future: vecinosCollection.doc(vecinos[index]).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data!.data() != null) {
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return FutureBuilder<DocumentSnapshot>(
                                    future:
                                        usersCollection.doc(data['uid']).get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.done) {
                                        Map<String, dynamic> userData =
                                            userSnapshot.data!.data()
                                                as Map<String, dynamic>;
                                        if (widget.admin &&
                                            data['uid'] != widget.uid) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Slidable(
                                              endActionPane: ActionPane(
                                                  motion: const ScrollMotion(),
                                                  children: <Widget>[
                                                    SlidableAction(
                                                        borderRadius:
                                                            slidableBorderRadius,
                                                        onPressed: (BuildContext
                                                            context) async {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                        title: Text(
                                                                            '¿Quieres nombrar a ${userData['name']} como presidente?'),
                                                                        actions: <Widget>[
                                                                          TextButton(
                                                                            child:
                                                                                const Text('Cancelar'),
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                          ),
                                                                          TextButton(
                                                                            child:
                                                                                const Text('Sí'),
                                                                            onPressed:
                                                                                () async {
                                                                              await DatabaseService(uid: data['uid']).updateUserData(userData['name'], userData['floor'], userData['community'], true);
                                                                              await DatabaseService(uid: widget.uid).updateUserData(widget.name, widget.floor, widget.userCommunity, false);
                                                                              await removeItem(data['uid'], vecinos);
                                                                              setState(() {});
                                                                              Navigator.pop(context);
                                                                            },
                                                                          )
                                                                        ],
                                                                      ));
                                                        },
                                                        backgroundColor: Colors
                                                            .blueAccent[700]!
                                                            .withOpacity(1),
                                                        icon: Icons.person),
                                                    SlidableAction(
                                                      onPressed: (BuildContext
                                                          context) async {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title: Text(
                                                                          '¿Quieres eliminar a ${userData['name']} de la comunidad?'),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Cancelar'),
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Eliminar'),
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.pop(context);
                                                                            await DatabaseService(uid: data['uid']).updateUserData(
                                                                                userData['name'],
                                                                                userData['floor'],
                                                                                'Sin comunidad asignada',
                                                                                false);
                                                                            await DatabaseService(uid: data['uid'], communityName: widget.userCommunity).updateCommunityUsersData(true);
                                                                            await removeItem(data['uid'],
                                                                                vecinos);
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
                                              child: Card(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 20, 0),
                                                child: ListTile(
                                                    title:
                                                        Text(userData['name']),
                                                    subtitle: Text(
                                                        userData['floor'])),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Card(
                                              margin: const EdgeInsets.fromLTRB(
                                                  20, 16, 20, 0),
                                              child: ListTile(
                                                  title: Text(userData['name']),
                                                  subtitle:
                                                      Text(userData['floor'])));
                                        }
                                      } else {
                                        return const Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Card(
                                                margin: EdgeInsets.fromLTRB(
                                                    20, 6, 20, 0),
                                                child: ListTile(
                                                    title: Text(
                                                        'Cargando.....'))));
                                      }
                                    });
                              }
                              return const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Card(
                                      margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                      child: ListTile(
                                          title: Text('Cargando....'))));
                            }
                            return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Card(
                                    margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                    child:
                                        ListTile(title: Text('Cargando...'))));
                          });
                    });
              }),
        ],
      ),
    );
  }
}
