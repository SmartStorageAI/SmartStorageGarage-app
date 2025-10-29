import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviso de Privacidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'AVISO DE PRIVACIDAD – SMART STORAGE GARAGE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'En Smart Storage Garage nos comprometemos profundamente con la protección de tus datos personales. Reconocemos que la confianza de nuestros usuarios es un pilar fundamental, y por ello cumplimos de manera estricta con la Ley Federal de Protección de Datos Personales en Posesión de Particulares (LFPDPPP) y demás normativas aplicables en México.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'El presente Aviso de Privacidad tiene como objetivo informarte de manera clara, transparente y accesible sobre la manera en que recopilamos, utilizamos, resguardamos y conservamos tus datos personales, garantizando siempre tu derecho a la privacidad.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '1. Consentimiento informado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Antes de recopilar cualquier dato personal, solicitamos tu consentimiento expreso, asegurándonos de que comprendas claramente qué información solicitamos y con qué finalidad. Nos esforzamos por presentar esta información de manera transparente, para que puedas tomar decisiones plenamente informadas sobre el uso de tus datos.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '2. Finalidad de la recopilación de datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Los datos que nos proporcionas son utilizados exclusivamente para:\n\n• Brindarte soporte y asistencia personalizada a través de nuestro chat, asegurando una experiencia eficiente y confiable.\n\n• Mejorar de manera continua la funcionalidad, rendimiento y seguridad de la aplicación, adaptándola a tus necesidades.\n\n• Enviarte notificaciones relevantes relacionadas con tu cuenta, los servicios que utilizas o actualizaciones importantes de la app.\n\nSolo solicitamos y procesamos la información estrictamente necesaria para cumplir con estas finalidades, evitando recopilar datos innecesarios.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '3. Seguridad de los datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Implementamos rigurosas medidas técnicas y administrativas para proteger tus datos frente a accesos no autorizados, pérdida, alteración o divulgación indebida. Adicionalmente, utilizamos protocolos de cifrado avanzados para la transmisión y almacenamiento de información sensible, garantizando que tu privacidad esté siempre resguardada.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '4. Derechos de los usuarios (ARCO)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Como usuario, tienes derechos plenos sobre tus datos personales, incluyendo Acceder, Rectificar, Cancelar y Oponerte a su tratamiento. Para ejercer estos derechos, puedes comunicarte con nosotros mediante: [correo de contacto], y nuestro equipo atenderá tu solicitud de manera oportuna y eficiente.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '5. Retención de datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tus datos personales serán conservados únicamente durante el tiempo estrictamente necesario para cumplir con las finalidades para las que fueron recopilados. Una vez cumplido este propósito, procederemos a su eliminación segura y definitiva, asegurando que no queden registros innecesarios.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '6. Política de privacidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Nuestra política de privacidad está disponible y accesible en todo momento, describiendo de manera detallada cómo recopilamos, usamos, protegemos y administramos tus datos personales, con la intención de brindarte tranquilidad y certeza sobre la seguridad de tu información.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '7. Transferencia de datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'En caso de que sea necesario transferir tus datos a terceros, esto se realizará únicamente con tu consentimiento previo, garantizando que la transferencia cumpla con la legislación vigente y con los más altos estándares de seguridad y confidencialidad.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '8. Notificación de brechas de seguridad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Si llegara a presentarse cualquier brecha de seguridad que pueda comprometer tus datos personales, nos comprometemos a notificarte de manera inmediata y conforme a los plazos establecidos por la LFPDPPP, tomando todas las medidas necesarias para mitigar cualquier riesgo.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'El uso continuado de nuestra aplicación implica la aceptación plena de las prácticas y medidas descritas en este Aviso de Privacidad, asegurando una relación transparente y de confianza entre nuestros usuarios y Smart Storage Garage.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}