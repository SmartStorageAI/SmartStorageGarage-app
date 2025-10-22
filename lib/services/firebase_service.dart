import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Obtener los datos del usuario por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final query = await _db.collection('users').where('email', isEqualTo: email).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  // 🔹 Obtener contenedores por nombres (array)
  Future<List<Map<String, dynamic>>> getContainersByNames(List<String> containerNames) async {
    if (containerNames.isEmpty) return [];

    final query = await _db
        .collection('containers')
        .where('nombre', whereIn: containerNames)
        .get();

    return query.docs.map((e) => e.data()).toList();
  }
}
