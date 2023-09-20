import 'package:flutter/material.dart';
import 'package:mi_comunidad/pages/communities/community_list.dart';
import 'package:mi_comunidad/pages/loading_spin.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:provider/provider.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:mi_comunidad/shared/constants.dart';

class Communities extends StatefulWidget {
  const Communities({Key? key}) : super(key: key);

  @override
  State<Communities> createState() => _CommunitiesState();
}

class _CommunitiesState extends State<Communities> {
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
                if (userData != null) {
                  return Scaffold(
                    backgroundColor: backgroundColor,
                    appBar: AppBar(
                        toolbarHeight: 80,
                        title: const Text('Comunidades',
                            style:
                                TextStyle(fontSize: 32, color: Colors.white)),
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
                    body: CommunityList(previousCommunity: userData.community),
                  );
                } else {
                  return const LoadingSpin();
                }
              } else {
                return const LoadingSpin();
              }
            });
  }
}
