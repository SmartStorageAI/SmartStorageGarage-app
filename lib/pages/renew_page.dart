import 'package:flutter/material.dart';
import '../services/n8n_service.dart';

class RenewPage extends StatelessWidget {
  const RenewPage({super.key});

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF758EB7);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Renovar Membresía'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed:() => (), /*async {
            await N8nService.sendPaymentRequest('usuario@ejemplo.com');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud enviada a n8n 💸')),
            );
          },*/
          style: ElevatedButton.styleFrom(
            backgroundColor: azul,
            foregroundColor: Colors.white,
          ),
          child: const Text('Renovar ahora'),
        ),
      ),
    );
  }
}
