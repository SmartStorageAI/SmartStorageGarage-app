import 'package:flutter/material.dart';
import 'package:ss_app/pages/main_page.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'privacy_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  String membresia = 'mensual';
  bool acceptedPrivacy = false; // <-- Nueva variable

  void _register() async {
    if (!acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar el Aviso de Privacidad')),
      );
      return;
    }

    final user = await _authService.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nombre: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      membresia: membresia,
    );

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        'membresia': membresia,
        'estadoPago': 'pendiente',
        'contenedores': [],
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainPage(userEmail: user.email!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Registro', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: membresia,
                items: const [
                  DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                  DropdownMenuItem(value: 'anual', child: Text('Anual')),
                ],
                onChanged: (v) => setState(() => membresia = v!),
              ),
              const SizedBox(height: 20),
              
              // Casilla de privacidad
              Row(
                children: [
                  Checkbox(
                    value: acceptedPrivacy,
                    onChanged: (value) {
                      setState(() {
                        acceptedPrivacy = value ?? false;
                      });
                    },
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrivacyPage()),
                        );
                      },
                      child: const Text(
                        'Acepto el Aviso de Privacidad',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              ElevatedButton(
                onPressed: acceptedPrivacy ? _register : null, // solo habilitado si acepta
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
