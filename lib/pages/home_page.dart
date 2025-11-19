import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'container_details_page.dart';

class HomePage extends StatelessWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFFA18CD1);
    const azul = Color(0xFF758EB7);
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getUserData(userEmail),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No se encontró información del usuario.'));
              }

              final userData =
                  userSnapshot.data!.docs.first.data() as Map<String, dynamic>;

              final userName = userData['nombre'] ?? 'Usuario';
              final membresia = userData['membresia'] ?? 'N/A';
              final estadoPago = userData['estadoPago'] ?? 'N/A';
              final userEmailData = userData['email'] ?? 'N/A';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // * HEADER BONITO *
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [morado, azul],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hola, $userName ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userEmailData,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // * TARJETAS DE INFO *
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          title: "Membresía",
                          value: membresia,
                          icon: Icons.card_membership,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard(
                          title: "Estado de pago",
                          value: estadoPago,
                          icon: Icons.payment,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Tus contenedores",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: azul,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // * LISTA DE CONTENEDORES *
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getUserContainers(userName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No tienes contenedores registrados."));
                        }

                        final containers = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: containers.length,
                          itemBuilder: (context, index) {
                            final containerDoc = containers[index];
                            final data = containerDoc.data() as Map<String, dynamic>;
                            
                            // Si tiene cliente, el estado debe ser ocupado
                            final hasCliente = data['cliente'] != null && 
                                             (data['cliente'] as String).isNotEmpty;
                            final ocupado = hasCliente ? true : (data['status'] == true);
                            
                            final containerId = containerDoc.id;
                            final containerName = data['nombre'] ?? 'Contenedor';

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContainerDetailsPage(
                                      containerId: containerId,
                                      containerName: containerName,
                                      containerSize: data['size'],
                                      containerStatus: ocupado,
                                      containerCliente: data['cliente'],
                                      containerUbicacion: data['ubicacion'],
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_rounded,
                                      color: ocupado
                                          ? morado
                                          : Colors.green,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            containerName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: azul,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text("Tamaño: ${data['size']}"),
                                        Text(
                                          "Estado: ${ocupado ? "Ocupado" : "Libre"}",
                                          style: TextStyle(
                                            color: ocupado
                                                ? morado
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ],
                                ),
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
      ),
    );
  }

  // * Tarjetas rápidas *
  Widget _infoCard({required String title, required String value, required IconData icon}) {
    const azul = Color(0xFF758EB7);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: azul, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: azul,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
