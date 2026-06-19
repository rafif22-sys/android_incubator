// lib/models/sensor_data.dart

class SensorData {
  final double temperature;   // DHT22 suhu (°C)
  final double humidity;      // DHT22 kelembapan (%)
  final double lumen;         // LDR cahaya (lux)
  final double tempBmp;       // BMP280 suhu (°C)
  final double pressure;      // BMP280 tekanan (hPa)
  final double altitude;      // BMP280 ketinggian (m)
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
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity:    (json['humidity']    ?? 0).toDouble(),
      lumen:       (json['lumen']       ?? 0).toDouble(),
      tempBmp:     (json['temp_bmp']    ?? 0).toDouble(),
      pressure:    (json['pressure']    ?? 0).toDouble(),
      altitude:    (json['altitude']    ?? 0).toDouble(),
      timestamp:   DateTime.now(),
    );
  }

  // Status kondisi inkubator
  String get tempStatus {
    if (temperature >= 37.0 && temperature <= 38.5) return 'Optimal';
    if (temperature < 37.0) return 'Terlalu Dingin';
    return 'Terlalu Panas';
  }

  String get humidityStatus {
    if (humidity >= 60.0 && humidity <= 70.0) return 'Optimal';
    if (humidity < 60.0) return 'Terlalu Kering';
    return 'Terlalu Lembap';
  }

  bool get isTempAlert    => temperature < 37.0 || temperature > 38.5;
  bool get isHumidAlert   => humidity < 60.0 || humidity > 70.0;
  bool get hasAlert       => isTempAlert || isHumidAlert;
}
