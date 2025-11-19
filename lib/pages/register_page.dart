import 'package:flutter/material.dart';
import 'package:ss_app/pages/main_page.dart';
import '../services/auth_service.dart';
import 'privacy_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool acceptedPrivacy = false;
  bool isLoading = false;
  bool _obscurePassword = true;

  // ---------- VALIDACIONES ----------
  String? _validateNombre(String? value) {
    if (value == null || value.trim().isEmpty) return 'Por favor ingresa tu nombre';
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$');
    if (!regex.hasMatch(value.trim())) return 'Nombre inválido. Usa solo letras y espacios';
    return null;
  }

  String? _validateTelefono(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingresa tu número telefónico';
    final regex = RegExp(r'^[0-9]{10}$');
    if (!regex.hasMatch(value)) return 'El número debe tener exactamente 10 dígitos';
    return null;
  }

  String? _validateCorreo(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingresa tu correo electrónico';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Formato de correo no válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingresa una contraseña';
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    if (!regex.hasMatch(value)) return 'Debe tener al menos 8 caracteres, \nuna mayúscula, un número y un símbolo';
    return null;
  }

  // ---------- REGISTRO ----------
  Future<void> _register() async {
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

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFFA18CD1);
    const azul = Color(0xFF758EB7);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return Container(
              margin: const EdgeInsets.all(20),
              height: 600,
              width: isMobile ? double.infinity : 900,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))],
              ),
              child: Row(
                children: [
                  // FORMULARIO
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // <- CENTRAR TODO
                            children: [
                              const Text(
                                "Registro",
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: azul),
                                textAlign: TextAlign.center, // <- CENTRAR TEXTO
                              ),
                              const SizedBox(height: 10),
                              // NOMBRE
                              TextFormField(
                                controller: _nombreController,
                                decoration: _inputDecoration('Nombre', Icons.person),
                                validator: _validateNombre,
                              ),
                              const SizedBox(height: 15),
                              // TELÉFONO
                              TextFormField(
                                controller: _telefonoController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration('Teléfono', Icons.phone),
                                validator: _validateTelefono,
                              ),
                              const SizedBox(height: 15),
                              // EMAIL
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration('Correo', Icons.email),
                                validator: _validateCorreo,
                              ),
                              const SizedBox(height: 15),
                              // PASSWORD
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: _inputDecoration(
                                  'Contraseña',
                                  Icons.lock,
                                  suffix: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Checkbox(
                                    value: acceptedPrivacy,
                                    onChanged: (v) => setState(() => acceptedPrivacy = v ?? false),
                                  ),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const PrivacyPage()),
                                      ),
                                      child: const Text(
                                        'Acepto el Aviso de Privacidad',
                                        style: TextStyle(decoration: TextDecoration.underline, color: Color(0xFF085A9E)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: azul,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                        )
                                      : const Text('Registrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // GRADIENTE + LOGO
                  if (!isMobile)
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [morado, azul], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Smart Storage Garage",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 25),
                                Image.asset('assets/icons/app_icon.png', width: 180, height: 180, fit: BoxFit.contain),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF758EB7)),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF758EB7), width: 2)),
    );
  }
}
