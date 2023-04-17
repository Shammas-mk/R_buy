class UserModel {
  String? uid;
  String? email;
  String? name;
  String? token;
  bool? isSub;

  UserModel({this.uid, this.email, this.name, this.token, this.isSub});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      token: map['token'],
      isSub: map['isSub'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'token': token,
      'isSub': isSub,
    };
  }
}
