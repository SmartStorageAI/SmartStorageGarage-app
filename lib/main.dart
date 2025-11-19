import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ss_app/pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/privacy_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartStorageApp());
}

class SmartStorageApp extends StatelessWidget {
  const SmartStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores del login
    const morado = Color(0xFFA18CD1);
    const azul = Color(0xFF758EB7);
    
    return MaterialApp(
      title: 'Smart Storage App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: azul,
          primary: azul,
          secondary: morado,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: azul,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: azul,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: azul, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        useMaterial3: true,
      ),

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as String?;
          return MainPage(userEmail: args ?? '');
        },
        '/privacy': (context) => const PrivacyPage(),
      },
    );
  }
}
