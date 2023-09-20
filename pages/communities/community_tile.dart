import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityTile extends StatefulWidget {
  const CommunityTile({Key? key, required this.community}) : super(key: key);
  final String? community;

  @override
  State<CommunityTile> createState() => _CommunityTileState();
}

class _CommunityTileState extends State<CommunityTile> {
  @override
  Widget build(BuildContext context) {
    CollectionReference communitiesCollection =
        FirebaseFirestore.instance.collection('communities');
    late final Future<DocumentSnapshot> getter =
        communitiesCollection.doc(widget.community).get();
    return FutureBuilder<DocumentSnapshot>(
        future: getter,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.data() != null) {
              Map<String?, dynamic> data =
                  snapshot.data!.data() as Map<String?, dynamic>;
              return Text(data['name']);
            }
            return const Text('Cargando...');
          }
          return Container();
        }));
  }
}
