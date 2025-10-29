# Smart Storage App

**Smart Storage** es una aplicación móvil desarrollada en **Flutter** que permite a los usuarios gestionar y monitorear de forma inteligente el uso de espacios de almacenamiento, integrando autenticación segura con **Firebase Auth**, almacenamiento en la nube con **Firestore**, y un chatbot asistente conectado mediante **n8n**.

---

## Características principales

- **Registro y autenticación seguras** mediante Firebase Auth.  
- **Validación de datos en cliente** (nombre, correo, teléfono y contraseña).  
- **Integración con Firestore** para manejo en tiempo real de datos.  
- **Chatbot asistente inteligente**, conectado con flujo automatizado de n8n.  
- **Pantalla de privacidad y aviso legal**, cumpliendo normativas de protección de datos.  
- **UI moderna y adaptable**, desarrollada con principios de diseño Material 3.

---

## Seguridad implementada

| Criterio | Descripción |
|----------|--------------|
| **Validación y saneamiento** | Los campos del formulario (nombre, correo, teléfono y contraseña) se validan desde el cliente para evitar inyecciones o datos inválidos. |
| **Autenticación robusta** | Se utiliza Firebase Authentication con verificación de correo electrónico y tokens gestionados por Firebase. |
| **Gestión de secretos** | No se almacenan llaves ni credenciales en el cliente; la configuración de Firebase está protegida mediante `firebase_options.dart`. |
| **Criptografía** | Firebase cifra las contraseñas automáticamente mediante hash seguro (bcrypt). En la versión final se incluirá cifrado local de datos sensibles (AES-GCM). |
| **Protección en servidor** | Firestore almacena la información de usuarios con reglas de seguridad personalizadas, restringiendo acceso solo a usuarios autenticados. |
| **Permisos y privacidad** | Se solicitan permisos mínimos y justificados (por ejemplo, acceso a internet). Se incluye aviso de privacidad. |
| **Seguridad en tránsito** | Toda la comunicación se realiza sobre **TLS 1.3** mediante HTTPS. No se permiten conexiones inseguras. |
| **Cumplimiento OWASP Mobile Top 10** | Se mitigan riesgos M1, M2, M5, M8 y M9 con validación, cifrado, autenticación segura y protección de datos en tránsito. |

---

## 🧠 Estructura del proyecto:
lib/
├── assets/
├── models/
│ ├── container_model.dart
│ └── user_model.dart
├── pages/
│ ├── chatbot/
│ ├── home/
│ ├── login/
│ ├── main_page.dart
│ ├── privacy_page.dart
│ ├── register_page.dart
│ └── renew_page.dart
├── routes/
│ └── app_routes.dart
├── services/
│ ├── auth_service.dart
│ ├── chatbot_service.dart
│ ├── firebase_service.dart
│ └── n8n_service.dart
├── widgets/
│ ├── chat_bubble.dart
│ ├── container_card.dart
│ └── custom_button.dart
├── firebase_options.dart
└── main.dart


##Próximas mejoras

Cifrado local de contraseñas y tokens (AES-GCM).

Implementación de refresh tokens y expiración rotatoria.

Integración de KeyStore/Keychain para gestión de secretos.

Checklist MASVS y documentación de pruebas de seguridad.

Pipeline CI con análisis estático y lint automático.

