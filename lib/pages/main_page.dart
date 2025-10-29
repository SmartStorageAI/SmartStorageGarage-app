import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'chatbot_page.dart';
import 'renew_page.dart';
import 'privacy_page.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MainPage extends StatefulWidget {
  final String userEmail; // ← recibe el correo del usuario

  const MainPage({super.key, required this.userEmail});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de páginas (Home recibe el correo también)
    final List<Widget> pages = [
      HomePage(userEmail: widget.userEmail),
      const ChatbotPage(),
      const RenewPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Storage App'),
      ),

      // Drawer con la info del usuario
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
                  accountEmail: Text(userData['email'] ?? 'correo@ejemplo.com'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 0, 23, 97),
                    child: Text(
                      userData['nombre'] != null &&
                              userData['nombre'].isNotEmpty
                          ? userData['nombre'][0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 23, 97),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mi cuenta'),
                  onTap: () {
                    Navigator.pop(context);
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
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Cerrar sesión'),
  onTap: () async {
    // Cierra Drawer
    Navigator.pop(context);

    // Cierra sesión en Firebase Auth
    await FirebaseAuth.instance.signOut();

    // Lleva al usuario al LoginPage
    Navigator.pushReplacementNamed(context, '/login');
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
        selectedItemColor: const Color.fromARGB(255, 0, 23, 97),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'Membresía'),
        ],
      ),
    );
  }
}
