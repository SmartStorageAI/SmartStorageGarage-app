import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';   

class ChatService extends ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  // --- MÉTODO PARA ENVIAR MENSAJE DEL USUARIO ---
  void sendUserMessage(String text) {
    _messages.add({
      "text": text,
      "isUser": true,
    });
    notifyListeners();

    // Aquí simulas respuesta de IA (solo por mientras)
    Future.delayed(const Duration(milliseconds: 600), () {
      _messages.add({
        "text": "Respuesta automática: $text",
        "isUser": false,
      });
      notifyListeners();
    });
  }
}
