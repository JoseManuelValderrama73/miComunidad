import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_comunidad/models/user_data.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:mi_comunidad/models/new_community.dart';

class DatabaseService {
  final String? uid;
  final String? communityName;
  DatabaseService({this.uid, this.communityName});

  // collection reference
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference communitiesCollection =
      FirebaseFirestore.instance.collection('communities');

  Future updateUserData(
      String name, String floor, String? community, bool admin) async {
    return await usersCollection.doc(uid).set(
        {'name': name, 'floor': floor, 'community': community, 'admin': admin});
  }

  // Update all community data
  Future updateCommunityData(String? name, String? adress) async {
    return await communitiesCollection
        .doc(name)
        .set({'name': name, 'adress': adress});
  }

  Future deleteCommunity() async {
    return await communitiesCollection.doc(communityName).delete();
  }

  Future updateCommunityUsersData(bool delete) async {
    if (communityName != null && uid != null) {
      if (delete == false) {
        return await FirebaseFirestore.instance
            .collection('communities/$communityName/communityUsers')
            .doc(uid)
            .set({'uid': uid});
      } else {
        return await FirebaseFirestore.instance
            .collection('communities/$communityName/communityUsers')
            .doc(uid)
            .delete();
      }
    } else {
      return null;
    }
  }

  Future updateCommunityPendingUsersData(bool delete) async {
    if (communityName != null && uid != null) {
      if (delete == false) {
        return await FirebaseFirestore.instance
            .collection('communities/$communityName/pendingUsers')
            .doc(uid)
            .set({'uid': uid});
      } else {
        return await FirebaseFirestore.instance
            .collection('communities/$communityName/pendingUsers')
            .doc(uid)
            .delete();
      }
    } else {
      return null;
    }
  }

  Future updateIncidenciasData(String? name, bool done) async {
    if (communityName != null) {
      return await FirebaseFirestore.instance
          .collection('communities/$communityName/incidencias')
          .doc(name)
          .set({'name': name, 'done': done});
    } else {
      return null;
    }
  }

  Future deleteIncidencias(String? name) async {
    if (communityName != null) {
      return await FirebaseFirestore.instance
          .collection('communities/$communityName/incidencias')
          .doc(name)
          .delete();
    } else {
      return null;
    }
  }

  Future updateReunionesData(String? date, String? description) async {
    if (communityName != null) {
      return await FirebaseFirestore.instance
          .collection('communities/$communityName/reuniones')
          .doc(description)
          .set({'date': date, 'description': description});
    } else {
      return null;
    }
  }

  Future deleteReuniones(String description) async {
    if (communityName != null) {
      return await FirebaseFirestore.instance
          .collection('communities/$communityName/reuniones')
          .doc(description)
          .delete();
    } else {
      return null;
    }
  }

  // users list from snapshot
  List<UserData> userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
        name: doc.get('name') ?? '',
        floor: doc.get('floor') ?? '',
        community: doc.get('community') ?? '',
        admin: doc.get('admin') ?? false,
      );
    }).toList();
  }

  List<Incidencias> _incidenciasListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Incidencias(
          description: doc.get('description') ?? '',
          done: doc.get('done') ?? false);
    }).toList();
  }

  List<Reuniones> _reunionesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Reuniones(
          date: doc.get('date') ?? '',
          description: doc.get('description') ?? '');
    }).toList();
  }

  UserDataWithUID _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserDataWithUID(
        uid: uid,
        name: snapshot['name'],
        floor: snapshot['floor'],
        community: snapshot['community'],
        admin: snapshot['admin']);
  }

  // get users stream
  Stream<List<UserData>> get userData {
    return usersCollection.snapshots().map(userListFromSnapshot);
  }

  Stream<UserDataWithUID> get userDataWithUID {
    return usersCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  //get community data

  Stream<List<Incidencias>> get incidenciasData {
    return FirebaseFirestore.instance
        .collection('communities/comunidad1/incidencias')
        .snapshots()
        .map(_incidenciasListFromSnapshot);
  }

  Stream<List<Reuniones>> get reunionesData {
    return communitiesCollection.snapshots().map(_reunionesListFromSnapshot);
  }
}
