import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/firebase_service.dart';
import 'container_details_page.dart';

/// Colores base que usamos en la pantalla
const Color kMorado = Color(0xFFA18CD1);
const Color kAzul = Color(0xFF758EB7);

class HomePage extends StatelessWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  // ─────────────────────────────────────────────────────────────
  //  CREDENCIALES PARA EL RTDB DEL PROYECTO smartstorage-garage
  //  (NO TOCAR)
  // ─────────────────────────────────────────────────────────────
  static const FirebaseOptions _rtdbOptions = FirebaseOptions(
    apiKey: "AIzaSyBvZfUULEFGd9pMBmkCoJGwsbPRW4M3L0k",
    authDomain: "smartstorage-garage.firebaseapp.com",
    databaseURL: "https://smartstorage-garage-default-rtdb.firebaseio.com",
    projectId: "smartstorage-garage",
    storageBucket: "smartstorage-garage.firebasestorage.app",
    messagingSenderId: "521685382172",
    appId: "1:521685382172:web:556ebf73794c0cfbbc1bd9",
    measurementId: "G-VZC9GMDXXD",
  );

  static FirebaseApp? _rtdbApp;

  Future<FirebaseDatabase> _getRtdb() async {
    // Inicializamos solo una vez este app secundario
    _rtdbApp ??= await Firebase.initializeApp(
      name: 'smartstorage-garage-rtdb',
      options: _rtdbOptions,
    );

    return FirebaseDatabase.instanceFor(
      app: _rtdbApp!,
      databaseURL: _rtdbOptions.databaseURL!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    // Primero aseguramos la app de RTDB con las credenciales correctas
    return FutureBuilder<FirebaseDatabase>(
      future: _getRtdb(),
      builder: (context, dbSnapshot) {
        if (dbSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final rtdb = dbSnapshot.data!;

        // Luego cargamos los datos del usuario desde Firestore
        return StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getUserData(userEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Valores por defecto
            String userName = 'Usuario';
            String membership = 'N/A';
            String estadoPago = 'pendiente';
            String userEmailData = userEmail;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final doc = snapshot.data!.docs.first;
              final userData = doc.data() as Map<String, dynamic>;

              userName = userData['name'] ?? userName;
              membership = userData['membership'] ?? membership;
              estadoPago = userData['estadoPago'] ?? estadoPago;
              userEmailData = userData['email'] ?? userEmailData;
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kMorado, kAzul],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, $userName",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            userEmailData,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: "Membresía",
                                  value: membership,
                                  icon: Icons.storage,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: "Estado de pago",
                                  value: estadoPago,
                                  icon: Icons.payment,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Tus contenedores",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ).copyWith(color: kAzul),
                    ),

                    const SizedBox(height: 10),

                    // Tarjetas de monitoreo (ESP32 / RTDB)
                    MonitoreoResumenInicio(database: rtdb),

                    const SizedBox(height: 16),

                    // LISTA DE CONTENEDORES (FIRESTORE)
                    StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getUserContainers(userName),
                      builder: (context, contSnapshot) {
                        if (contSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!contSnapshot.hasData ||
                            contSnapshot.data!.docs.isEmpty) {
                          // ⬇️ Ya no mostramos el texto "No tienes contenedores registrados"
                          return const SizedBox.shrink();
                        }

                        final containers = contSnapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: containers.length,
                          itemBuilder: (context, index) {
                            final containerData = containers[index];
                            final data =
                                containerData.data() as Map<String, dynamic>;
                            final containerName =
                                data['name'] ?? 'Contenedor sin nombre';
                            final ocupado = data['occupied'] ?? false;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContainerDetailsPage(
                                      containerId: containerData.id,
                                      containerName: containerName,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_rounded,
                                      color: ocupado ? kMorado : Colors.green,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            containerName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: kAzul,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Tamaño: ${data['size'] ?? '-'}",
                                          ),
                                          Text(
                                            ocupado
                                                ? "Estado: Ocupado"
                                                : "Estado: Libre",
                                            style: TextStyle(
                                              color: ocupado
                                                  ? Colors.redAccent
                                                  : Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purple.shade400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────
//  TARJETAS DE MONITOREO (RTDB / SENSORES)
// ───────────────────────────────────────────────

class MonitoreoResumenInicio extends StatelessWidget {
  final FirebaseDatabase database;

  const MonitoreoResumenInicio({super.key, required this.database});

  double _parseDouble(dynamic v) {
    if (v == null) return double.nan;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? double.nan;
  }

  bool _isOcupada(double dist) {
    // mismo umbral que en la ESP32
    return dist.isFinite && dist > 0 && dist < 20;
  }

  @override
  Widget build(BuildContext context) {
    final sensoresRef = database.ref('sensores');

    return StreamBuilder<DatabaseEvent>(
      stream: sensoresRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Error al cargar datos de monitoreo.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final raw = snapshot.data?.snapshot.value;
        final data = (raw is Map) ? raw : <dynamic, dynamic>{};

        final b1 = (data['bodega1'] ?? {}) as Map;
        final b2 = (data['bodega2'] ?? {}) as Map;

        final dist1 = _parseDouble(b1['dist']);
        final dist2 = _parseDouble(b2['dist']);
        final temp2 = _parseDouble(b2['temp']);
        final hum2 = _parseDouble(b2['hum']);

        final ocupada1 = _isOcupada(dist1);
        final ocupada2 = _isOcupada(dist2);

        return Column(
          children: [
            _Bodega1Card(distancia: dist1, ocupada: ocupada1),
            const SizedBox(height: 12),
            _Bodega2Card(
              distancia: dist2,
              temperatura: temp2,
              humedad: hum2,
              ocupada: ocupada2,
            ),
          ],
        );
      },
    );
  }
}

// ----- Tarjeta Bodega 1 -----
class _Bodega1Card extends StatelessWidget {
  final double distancia;
  final bool ocupada;

  const _Bodega1Card({required this.distancia, required this.ocupada});

  @override
  Widget build(BuildContext context) {
    final distText = distancia.isFinite
        ? '${distancia.toStringAsFixed(1)} cm'
        : '--';

    final pillColor = ocupada
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);
    final pillText = ocupada ? 'OCUPADA' : 'LIBRE';

    final alertaText = ocupada
        ? 'Alarma activa (buzzer encendido)'
        : 'Sin alerta (buzzer apagado)';
    final alertaColor = ocupada ? Colors.red[300] : Colors.green[300];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B7FD6), // morado pastel
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // encabezado
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bodega 1',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sensor de ocupación',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pillText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Distancia',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            distText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),
          Text(alertaText, style: TextStyle(color: alertaColor, fontSize: 12)),

          const SizedBox(height: 6),
          Text(
            'Última actualización: ${TimeOfDay.now().format(context)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Tarjeta Bodega 2 -----
class _Bodega2Card extends StatelessWidget {
  final double distancia;
  final double temperatura;
  final double humedad;
  final bool ocupada;

  const _Bodega2Card({
    required this.distancia,
    required this.temperatura,
    required this.humedad,
    required this.ocupada,
  });

  @override
  Widget build(BuildContext context) {
    final distText = distancia.isFinite
        ? '${distancia.toStringAsFixed(1)} cm'
        : '--';
    final tempText = temperatura.isFinite
        ? '${temperatura.toStringAsFixed(1)} °C'
        : '--';
    final humText = humedad.isFinite ? '${humedad.toStringAsFixed(1)} %' : '--';

    final pillColor = ocupada
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);
    final pillText = ocupada ? 'OCUPADA' : 'LIBRE';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8076D4), // otro morado pastel
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // encabezado
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bodega 2',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ocupación, temperatura y humedad',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pillText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // métricas
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Distancia',
                  value: distText,
                  subtitle: 'Sensor sónico',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Temperatura',
                  value: tempText,
                  subtitle: 'DHT11 (°C)',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Humedad',
                  value: humText,
                  subtitle: 'DHT11 (%)',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Última actualización: ${TimeOfDay.now().format(context)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF5B3EA9), // morado más oscuro
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Las clases _BodegaCard y _DatoMini quedan por si luego quieres reutilizarlas,
// pero actualmente no se usan directamente en el layout.

class _BodegaCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool statusLibre;
  final Color morado;
  final Color azul;
  final Widget contenido;

  const _BodegaCard({
    required this.titulo,
    required this.subtitulo,
    required this.statusLibre,
    required this.morado,
    required this.azul,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = statusLibre
        ? const Color(0xFFB9F6CA)
        : const Color(0xFFFFCDD2);
    final statusBg = statusLibre
        ? const Color(0xFF1B5E20).withOpacity(0.2)
        : const Color(0xFFB71C1C).withOpacity(0.2);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [morado, azul],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLibre ? 'LIBRE' : 'OCUPADA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          contenido,
        ],
      ),
    );
  }
}

class _DatoMini extends StatelessWidget {
  final String label;
  final String value;
  final String unidad;

  const _DatoMini({
    required this.label,
    required this.value,
    required this.unidad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unidad,
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
