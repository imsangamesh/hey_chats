import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hey_chats/models/userModel.dart';

class FireBaseHelper {
  static Future<UserModel?> getUserModelByUid(String uid) async {
    UserModel? userModel;

    final DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
      return userModel;
    }
    return null;
  }
}
