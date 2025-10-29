import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTRO
  Future<User?> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String membresia,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'nombre': nombre,
          'telefono': telefono,
          'email': email,
          'membresia': membresia,
          'estadoPago': 'pendiente',
          'contenedores': [],
        });
      }
      return user;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // LOGIN
  Future<User?> loginUser(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // VER USUARIO ACTUAL
  User? get currentUser => _auth.currentUser;
}
