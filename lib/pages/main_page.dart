import 'package:flutter/material.dart';
import 'home_page.dart';
import 'chatbot_page.dart';
import 'renew_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatbotPage(),
    const RenewPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Storage App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header con info del usuario
            UserAccountsDrawerHeader(
              accountName: const Text('Helen Vega'),
              accountEmail: const Text('helen@ejemplo.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 0, 23, 97),
                child: const Text('H', style: TextStyle(fontSize: 24)),
              ),
            ),

            // Opciones del drawer
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi cuenta'),
              onTap: () {
                // Aquí puedes navegar a la página de perfil
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Aviso de privacidad'),
              onTap: () {
                // Aquí podrías abrir un AlertDialog o página con el aviso
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Aviso de Privacidad'),
                    content: const Text('Aquí va el texto del aviso de privacidad...'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      )
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // Aquí cerrarías sesión con Firebase Auth
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 23, 97),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Membresía'),
        ],
      ),
    );
  }
}
