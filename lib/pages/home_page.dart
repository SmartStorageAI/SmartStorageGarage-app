import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class HomePage extends StatelessWidget {
  final String userEmail;
  const HomePage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 247, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getUserData(userEmail),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No se encontró información del usuario.'),
              );
            }

            final userData =
                userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
            final userName = userData['nombre'] ?? 'Usuario';
            final membresia = userData['membresia'] ?? 'N/A';
            final estadoPago = userData['estadoPago'] ?? 'N/A';
            final userEmail = userData['email'] ?? 'N/A';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenid@, $userName ',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 23, 97),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Membresía: $membresia'),
                Text('Estado de pago: $estadoPago'),
                Text('E-mail: $userEmail'),

                const SizedBox(height: 20),
                const Text(
                  'Tus contenedores:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 0, 23, 97),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestoreService.getUserContainers(userName),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No tienes contenedores registrados.'));
                      }

                      final containers = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: containers.length,
                        itemBuilder: (context, index) {
                          final data = containers[index].data()
                              as Map<String, dynamic>;
                          return Card(
                            color: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.storage,
                                color: Color.fromARGB(255, 0, 23, 97),
                              ),
                              title: Text('Contenedor: ${data['nombre']}'),
                              subtitle: Text(
                                  'Tamaño: ${data['size']} | Estado: ${data['status'] ? "Ocupado" : "Libre"}'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
