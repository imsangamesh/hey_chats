import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier {
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;
  String? phone;
  String? about;
  bool success = false;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.profilePic,
    required this.phone,
    required this.about,
    required this.success,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    fullName = map['fullName'];
    email = map['email'];
    profilePic = map['profilePic'];
    phone = map['phone'];
    about = map['about'];
    success = map['success'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profilePic': profilePic,
      'phone': phone,
      'about': about,
      'success': success,
    };
  }
}
