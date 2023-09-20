class NewUser {
  late final String uid;
  NewUser({required this.uid});
}

class UserDataWithUID {
  final String? uid;
  final String name;
  final String floor;
  final String community;
  final bool admin;

  UserDataWithUID(
      {required this.uid,
      required this.name,
      required this.floor,
      required this.community,
      required this.admin});
}
