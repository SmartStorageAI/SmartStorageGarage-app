import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  final String userEmail;

  const AccountPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFFA18CD1);
    const azul = Color(0xFF758EB7);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No se encontró la información del usuario.'));
          }

          final userData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: morado,
                        backgroundImage: userData['profileImageUrl'] != null
                            ? NetworkImage(userData['profileImageUrl'])
                            : null,
                        child: userData['profileImageUrl'] == null
                            ? Text(
                                (userData['nombre'] != null &&
                                        (userData['nombre'] as String).isNotEmpty)
                                    ? userData['nombre'][0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    fontSize: 36, color: Colors.white),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('👤 Nombre: ${userData['nombre']}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('📧 Correo: ${userData['email']}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('📱 Teléfono: ${userData['telefono']}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('💳 Membresía: ${userData['membresia']}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('💰 Estado de pago: ${userData['estadoPago']}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
