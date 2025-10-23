import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserContainers(String userName) {
    return _db
        .collection('containers')
        .where('cliente', isEqualTo: userName)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserData(String email) {
    return _db
        .collection('users')
        .where('email', isEqualTo: email)
        .snapshots();
  }
}
