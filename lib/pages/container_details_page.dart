import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data_model.dart';
import '../services/firebase_service.dart';

class ContainerDetailsPage extends StatelessWidget {
  final String containerId;
  final String containerName;
  final String? containerSize;
  final bool? containerStatus;
  final String? containerCliente;
  final String? containerUbicacion;
  final FirestoreService firestoreService = FirestoreService();

  ContainerDetailsPage({
    super.key,
    required this.containerId,
    required this.containerName,
    this.containerSize,
    this.containerStatus,
    this.containerCliente,
    this.containerUbicacion,
  });

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFFA18CD1);
    const azul = Color(0xFF758EB7);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(containerName),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getContainerSensorData(containerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay datos reales, usar datos fake jiji
          final hasRealData = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
          final sensorDataList = hasRealData
              ? _processRealData(snapshot.data!.docs, containerId)
              : _generateFakeData();

          // Ordenar por timestamp (más antiguo primero para la gráfica)
          sensorDataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          // Obtener valores actuales (más recientes)
          final latestData = sensorDataList.isNotEmpty
              ? sensorDataList.last
              : SensorData(
                  timestamp: DateTime.now(),
                  temperature: 0,
                  humidity: 0,
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card con valores actuales
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [morado, azul],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Estado Actual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCurrentValue(
                            icon: Icons.thermostat,
                            label: 'Temperatura',
                            value: '${latestData.temperature.toStringAsFixed(1)}°C',
                            color: Colors.white,
                          ),
                          _buildCurrentValue(
                            icon: Icons.water_drop,
                            label: 'Humedad',
                            value: '${latestData.humidity.toStringAsFixed(1)}%',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card con gráfica de temperatura
                _buildChartCard(
                  title: 'Temperatura (°C)',
                  icon: Icons.thermostat,
                  color: Colors.red,
                  data: sensorDataList,
                  getValue: (data) => data.temperature,
                  yAxisLabel: '°C',
                ),

                const SizedBox(height: 16),

                // Card con gráfica de humedad
                _buildChartCard(
                  title: 'Humedad (%)',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  data: sensorDataList,
                  getValue: (data) => data.humidity,
                  yAxisLabel: '%',
                ),

                const SizedBox(height: 16),

                // Card con información del contenedor
                _buildContainerInfoCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Generar datos fake de sensores
  List<SensorData> _generateFakeData() {
    final now = DateTime.now();
    final List<SensorData> fakeData = [];
    
    // Generar 24 puntos de datos (últimas 24 horas)
    for (int i = 23; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Temperatura: variación entre 20°C y 30°C con patrón realista
      final baseTemp = 25.0;
      final variation = 5.0 * (i % 6) / 6.0;
      final temp = baseTemp + variation + (i % 3 - 1) * 1.5;
      
      // Humedad: variación entre 40% y 70% con patrón realista
      final baseHumidity = 55.0;
      final humidityVariation = 15.0 * (i % 8) / 8.0;
      final humidity = baseHumidity + humidityVariation + (i % 4 - 2) * 3.0;
      
      fakeData.add(SensorData(
        timestamp: timestamp,
        temperature: temp.clamp(20.0, 30.0),
        humidity: humidity.clamp(40.0, 70.0),
      ));
    }
    
    return fakeData;
  }

  // Procesar datos reales de Firestore
  List<SensorData> _processRealData(List<QueryDocumentSnapshot> docs, String containerId) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final dataWithTimestamp = Map<String, dynamic>.from(data);
      if (!dataWithTimestamp.containsKey('timestamp')) {
        dataWithTimestamp['timestamp'] = Timestamp.now();
      }
      if (!dataWithTimestamp.containsKey('containerId')) {
        dataWithTimestamp['containerId'] = containerId;
      }
      return SensorData.fromMap(dataWithTimestamp);
    }).where((data) => data.temperature != 0 || data.humidity != 0).toList();
  }

  Widget _buildContainerInfoCard() {
    const azul = Color(0xFF758EB7);
    const morado = Color(0xFFA18CD1);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: azul, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Información del Contenedor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: azul,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.inventory_2_rounded, 'Nombre', containerName),
          if (containerSize != null)
            _buildInfoRow(Icons.aspect_ratio, 'Tamaño', containerSize!),
          if (containerCliente != null && containerCliente!.isNotEmpty)
            _buildInfoRow(Icons.person, 'Cliente', containerCliente!),
          if (containerUbicacion != null && containerUbicacion!.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Ubicación', containerUbicacion!),
          if (containerStatus != null)
            _buildInfoRow(
              containerStatus! ? Icons.check_circle : Icons.cancel,
              'Estado',
              containerStatus! ? 'Ocupado' : 'Libre',
              valueColor: containerStatus! ? morado : Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    const azul = Color(0xFF758EB7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: azul, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? azul,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentValue({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<SensorData> data,
    required double Function(SensorData) getValue,
    required String yAxisLabel,
  }) {
    const azul = Color(0xFF758EB7);

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No hay datos para mostrar',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Preparar datos para la gráfica
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), getValue(entry.value));
    }).toList();

    // Calcular min y max para el eje Y
    final values = data.map(getValue).toList();
    final minValue = (values.reduce((a, b) => a < b ? a : b) * 0.9).floor().toDouble();
    final maxValue = (values.reduce((a, b) => a > b ? a : b) * 1.1).ceil().toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: azul,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxValue - minValue) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: data.length > 10 ? (data.length / 5).ceil().toDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final date = data[value.toInt()].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: (maxValue - minValue) / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(1)}$yAxisLabel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minValue,
                maxY: maxValue,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

