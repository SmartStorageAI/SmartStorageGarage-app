import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss_app/pages/user_profile_page.dart';
import 'home_page.dart';
import 'chatbot_page.dart';
import 'renew_page.dart';
import 'privacy_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatefulWidget {
  final String userEmail;

  const MainPage({super.key, required this.userEmail});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  // TIMER DE INACTIVIDAD
  Timer? _inactivityTimer;

  /// Reinicia el temporizador de inactividad
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 2), () async {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  /// Detecta si la app se pausó o volvió
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Si vuelve a la app, seguir con la sesión y reiniciar timer
      _resetInactivityTimer();
    }
  }

  void _onItemTapped(int index) {
    _resetInactivityTimer();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFFA18CD1);
    const azul = Color(0xFF758EB7);

    final List<Widget> pages = [
      HomePage(userEmail: widget.userEmail),
      const ChatbotPage(),
      const RenewPage(),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Storage App'),
          backgroundColor: azul,
          foregroundColor: Colors.white,
        ),

        drawer: Drawer(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: widget.userEmail)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No se encontró la cuenta.'));
              }

              final userData =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(userData['nombre'] ?? 'Usuario'),
                    accountEmail:
                        Text(userData['email'] ?? 'correo@ejemplo.com'),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: morado,
                      backgroundImage: userData['profileImageUrl'] != null
                          ? NetworkImage(userData['profileImageUrl'])
                          : null,
                      child: userData['profileImageUrl'] == null
                          ? Text(
                              userData['nombre'] != null &&
                                      userData['nombre'].isNotEmpty
                                  ? userData['nombre'][0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white),
                            )
                          : null,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [morado, azul],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Mi cuenta', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Aviso de privacidad'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyPage()),
                      );
                    },
                  ),

                  const Divider(),

                  // CERRAR SESIÓN CON CONFIRMACIÓN
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesión'),
                    onTap: () async {
                      Navigator.pop(context);

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("¿Salir?"),
                            content: const Text("¿De verdad quieres cerrar sesión?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancelar"),
                                onPressed: () =>
                                    Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text("Sí, cerrar"),
                                onPressed: () =>
                                    Navigator.pop(context, true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),

        body: pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: azul,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
            BottomNavigationBarItem(
                icon: Icon(Icons.payment), label: 'Membresía'),
          ],
        ),
      ),
    );
  }
}
