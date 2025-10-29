import 'package:flutter/material.dart';
import 'package:ss_app/pages/main_page.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'privacy_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  bool acceptedPrivacy = false;
  bool isLoading = false;
  bool _obscurePassword = true; // controla si se ve o no la contraseña

  // ---------- VALIDACIONES ----------
  String? _validateNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Nombre inválido. Usa solo letras y espacios';
    }
    return null;
  }

  String? _validateTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu número telefónico';
    }
    final regex = RegExp(r'^[0-9]{10}$');
    if (!regex.hasMatch(value)) {
      return 'El número debe tener exactamente 10 dígitos';
    }
    return null;
  }

  String? _validateCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Formato de correo no válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    if (!regex.hasMatch(value)) {
      return 'Debe tener al menos 8 caracteres, una mayúscula,\nun número y un símbolo (no puntos y comas)';
    }
    return null;
  }

  // ---------- REGISTRO ----------
  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar el Aviso de Privacidad')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        membresia: 'pendiente',
      );

      if (user != null) {
        final token = await user.getIdToken();
        await storage.write(key: 'auth_token', value: token);

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nombre': _nombreController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'email': _emailController.text.trim(),
          'estadoPago': 'pendiente',
          'contenedores': [],
          'tokenGuardado': true,
        });

        if (!mounted) return;
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error durante el registro: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child:  Form(
           key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // ✅ activa validación en tiempo real
             child: ListView(
         shrinkWrap: true,
          children: [
                const Text(
                  'Registro',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    errorMaxLines: 2,
                  ),
                  validator: _validateNombre,
                ),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    errorMaxLines: 2,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validateTelefono,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    errorMaxLines: 2,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateCorreo,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    errorMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),

                const SizedBox(height: 20),
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
                              builder: (_) => const PrivacyPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Acepto el Aviso de Privacidad',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color.fromARGB(255, 8, 90, 158),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrar',
                          style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
