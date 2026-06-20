
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

  String tempStatus(double minTemp, double maxTemp) {
    if (temperature >= minTemp &&
        temperature <= maxTemp) {
      return 'Optimal';
    }
    if (temperature < minTemp) {
      return 'Terlalu Dingin';
    }
    return 'Terlalu Panas';
  }

  String humidityStatus(double minHumid, double maxHumid) {
    if (humidity >= minHumid &&
        humidity <= maxHumid) {
      return 'Optimal';
    }
    if (humidity < minHumid) {
      return 'Terlalu Kering';
    }
    return 'Terlalu Lembap';
  }

  bool isTempAlert(double minTemp, double maxTemp) =>
      temperature < minTemp ||
      temperature > maxTemp;

  bool isHumidAlert(double minHumid, double maxHumid) =>
      humidity < minHumid || humidity > maxHumid;

  bool hasAlert(double minTemp, double maxTemp, double minHumid, double maxHumid) =>
      isTempAlert(minTemp, maxTemp) || isHumidAlert(minHumid, maxHumid);
}
