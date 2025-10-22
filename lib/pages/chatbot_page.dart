import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente Smart')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ChatBubble(text: '¡Hola! ¿En qué puedo ayudarte?', isUser: false),
        ],
      ),
    );
  }
}
