import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:mi_comunidad/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based in Firebase user
  NewUser? _userFromFirebaseUser(User? user) {
    return user != null ? NewUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<NewUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  String getUID(User user) {
    return user.uid;
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // sign in with email and pwd
  Future signInWithEmailAndPwd(String email, String pwd) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: pwd);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // register with email and pwd
  Future registerWithEmailAndPwd(
      String email, String pwd, String name, String floor) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: pwd);
      User? user = result.user;

      // create a new document for the user with the uid
      await DatabaseService(uid: user!.uid)
          .updateUserData(name, floor, 'Sin comunidad asignada', false);
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
