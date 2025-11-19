import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class N8nService {
  // Android emulator -> use 10.0.2.2
  // iOS simulator or web -> use localhost
  // physical device -> use your PC LAN IP (ej: http://192.168.0.5:5678/webhook/chatbot)
  static const String webhookUrl = 'http://192.168.1.102:5678/webhook/chatbot';

  /// Prueba la conexión con el servidor n8n
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final uri = Uri.parse(webhookUrl);
      final payload = jsonEncode({'message': 'test'});

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(
        const Duration(seconds: 10),
      );

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'body': response.body,
        'headers': response.headers.toString(),
      };
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Timeout: El servidor no respondió a tiempo',
      };
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: ${e.message}',
        'url': webhookUrl,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  /// Envía mensaje al webhook de n8n y devuelve la respuesta string.
  static Future<String> sendMessage(String message) async {
    final uri = Uri.parse(webhookUrl);
    final payload = jsonEncode({'message': message});

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(
        const Duration(seconds: 30),
      );

      // Debug: imprimir respuesta completa
      debugPrint('🔍 n8n Response Status: ${response.statusCode}');
      debugPrint('🔍 n8n Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Intentar parsear como JSON
        try {
          final json = jsonDecode(response.body);
          
          // n8n puede devolver diferentes formatos:
          // 1. { "message": "texto" }
          // 2. { "data": { "message": "texto" } }
          // 3. { "response": "texto" }
          // 4. String directo
          
          if (json is Map) {
            if (json.containsKey('message')) {
              final msg = json['message'];
              return msg.toString().trim();
            } else if (json.containsKey('data') && json['data'] is Map) {
              final data = json['data'] as Map;
              if (data.containsKey('message')) {
                return data['message'].toString().trim();
              } else {
                // Si data existe pero no tiene message, devolver el data completo
                return data.toString().trim();
              }
            } else if (json.containsKey('response')) {
              return json['response'].toString().trim();
            } else if (json.containsKey('text')) {
              return json['text'].toString().trim();
            } else {
              // Si es un Map pero no tiene los campos esperados, devolver el JSON completo
              return json.toString();
            }
          } else if (json is String) {
            return json.trim();
          } else {
            // Si no es Map ni String, devolver el body completo
            return response.body.trim();
          }
        } catch (e) {
          // Si no es JSON válido, devolver el body como texto
          debugPrint('⚠️ No se pudo parsear JSON: $e');
          return response.body.trim();
        }
      } else {
        throw Exception('Error n8n: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Timeout: El servidor no respondió a tiempo (30s)');
    } on SocketException {
      throw Exception('Error de conexión: No se pudo conectar al servidor. Verifica que n8n esté corriendo en $webhookUrl');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
