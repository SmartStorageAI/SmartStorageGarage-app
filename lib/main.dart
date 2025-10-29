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
    return MaterialApp(
      title: 'Smart Storage App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 115, 176, 247)),
        useMaterial3: true,
      ),

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) {
          // Esto es solo para referencia, normalmente pasamos email al construir MainPage
          final args =
              ModalRoute.of(context)!.settings.arguments as String?;
          return MainPage(userEmail: args ?? '');
        },
        '/privacy': (context) => const PrivacyPage(),
      },
    );
  }
}
