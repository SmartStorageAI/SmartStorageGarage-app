import 'package:flutter/material.dart';
import '../services/n8n_service.dart';

class RenewPage extends StatelessWidget {
  const RenewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Renovar Membresía')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await N8nService.sendPaymentRequest('usuario@ejemplo.com');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud enviada a n8n 💸')),
            );
          },
          child: const Text('Renovar ahora'),
        ),
      ),
    );
  }
}
