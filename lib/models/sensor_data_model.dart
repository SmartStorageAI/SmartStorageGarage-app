import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;

  SensorData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
  });

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp'].toString()),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
    };
  }
}

