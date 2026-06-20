import '../../core/constants/app_constants.dart';

class SensorData {
  final double temperature;
  final double humidity;
  final double lumen;
  final double tempBmp;
  final double pressure;
  final double altitude;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.lumen,
    required this.tempBmp,
    required this.pressure,
    required this.altitude,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      lumen: (json['lumen'] ?? 0.0).toDouble(),
      tempBmp: (json['temp_bmp'] ?? 0.0).toDouble(),
      pressure: (json['pressure'] ?? 0.0).toDouble(),
      altitude: (json['altitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  String get tempStatus {
    if (temperature >= AppThresholds.minTemp &&
        temperature <= AppThresholds.maxTemp) {
      return 'Optimal';
    }
    if (temperature < AppThresholds.minTemp) {
      return 'Terlalu Dingin';
    }
    return 'Terlalu Panas';
  }

  String get humidityStatus {
    if (humidity >= AppThresholds.minHumid &&
        humidity <= AppThresholds.maxHumid) {
      return 'Optimal';
    }
    if (humidity < AppThresholds.minHumid) {
      return 'Terlalu Kering';
    }
    return 'Terlalu Lembap';
  }

  bool get isTempAlert =>
      temperature < AppThresholds.minTemp ||
      temperature > AppThresholds.maxTemp;
  bool get isHumidAlert =>
      humidity < AppThresholds.minHumid || humidity > AppThresholds.maxHumid;
  bool get hasAlert => isTempAlert || isHumidAlert;
}
