import 'package:flutter/material.dart';

class ContainerCard extends StatelessWidget {
  final String containerName;
  final bool status;
  final String size;

  const ContainerCard({
    super.key,
    required this.containerName,
    required this.status,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          status ? Icons.check_circle : Icons.hourglass_empty,
          color: status ? Colors.green : Colors.orange,
        ),
        title: Text('Contenedor $containerName'),
        subtitle: Text('Tamaño: $size'),
        trailing: Text(
          status ? 'Ocupado' : 'Disponible',
          style: TextStyle(
            color: status ? Colors.redAccent : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
