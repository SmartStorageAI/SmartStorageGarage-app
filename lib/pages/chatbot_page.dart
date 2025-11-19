import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/n8n_service.dart';
import '../../widgets/chat_bubble.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_bubble.dart';


class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  bool _sending = false;
  bool _testingConnection = false;

  @override
  void initState() {
    super.initState();
    // Mensaje inicial del bot
    _messages.add(ChatMessage(text: '¡Hola! Soy tu asistente. ¿En qué puedo ayudarte hoy?', isUser: false));
  }

  Future<void> _testConnection() async {
    setState(() => _testingConnection = true);
    
    final result = await N8nService.testConnection();
    
    setState(() {
      _testingConnection = false;
      if (result['success'] == true) {
        _messages.insert(0, ChatMessage(
          text: 'Conexión exitosa!\nStatus: ${result['statusCode']}\nRespuesta: ${result['body']}', 
          isUser: false
        ));
      } else {
        _messages.insert(0, ChatMessage(
          text: 'Error de conexión:\n${result['error'] ?? 'Error desconocido'}\n${result['url'] != null ? 'URL: ${result['url']}' : ''}', 
          isUser: false
        ));
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Añadir mensaje del usuario a la lista
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _sending = true;
      _controller.clear();
    });

    try {
      final reply = await N8nService.sendMessage(text);
      setState(() {
        _messages.insert(0, ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.insert(0, ChatMessage(
          text: 'Error: ${e.toString().replaceAll('Exception: ', '')}', 
          isUser: false
        ));
      });
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF758EB7);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Asistente Smart'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _testingConnection 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_protected_setup),
            onPressed: _testingConnection ? null : _testConnection,
            tooltip: 'Probar conexión',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('No hay mensajes aún'))
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, idx) {
                        final msg = _messages[idx];
                        return ChatBubble(text: msg.text, isUser: msg.isUser);
                      },
                    ),
            ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration.collapsed(hintText: 'Escribe un mensaje...'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: _sending ? const CircularProgressIndicator() : const Icon(Icons.send),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
