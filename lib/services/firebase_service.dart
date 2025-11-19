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

  // Obtener datos de sensores de un contenedor
  Stream<QuerySnapshot> getContainerSensorData(String containerId) {
    return _db
        .collection('sensor_data')
        .where('containerId', isEqualTo: containerId)
        .orderBy('timestamp', descending: true)
        .limit(24) // Últimas 24 lecturas
        .snapshots();
  }

  // Obtener datos de sensores de un contenedor (sin stream, para datos históricos)
  Future<QuerySnapshot> getContainerSensorDataHistory(String containerId, {int limit = 24}) {
    return _db
        .collection('sensor_data')
        .where('containerId', isEqualTo: containerId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
  }
}
