import 'package:http/http.dart' as http;

class N8nService {
  static const String n8nWebhookUrl = 'https://tu-flujo-n8n.webhook.url';

  static Future<void> sendPaymentRequest(String userEmail) async {
    await http.post(
      Uri.parse(n8nWebhookUrl),
      body: {'email': userEmail, 'type': 'renew_membership'},
    );
  }
}
