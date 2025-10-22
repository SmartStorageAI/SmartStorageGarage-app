import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/container_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isLoading = true;
  List<Map<String, dynamic>> userContainers = [];

  // 👇 Aquí pondrás el email del usuario logueado (de momento fijo para probar)
  final String userEmail = 'usuario@ejemplo.com';

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  Future<void> _loadContainers() async {
    final userData = await _firebaseService.getUserByEmail(userEmail);
    if (userData == null) {
      setState(() => isLoading = false);
      return;
    }

    final containerNames = List<String>.from(userData['contenedores'] ?? []);
    final containers = await _firebaseService.getContainersByNames(containerNames);

    setState(() {
      userContainers = containers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Contenedores')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userContainers.isEmpty
              ? const Center(child: Text('No tienes contenedores asignados 😕'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userContainers.length,
                  itemBuilder: (context, index) {
                    final cont = userContainers[index];
                    return ContainerCard(
                      containerName: cont['nombre'] ?? 'Sin nombre',
                      status: cont['status'] ?? false,
                      size: cont['size'] ?? 'N/A',
                    );
                  },
                ),
    );
  }
}
