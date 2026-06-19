import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/historical_value.dart';

class UbidotsService {
  static const String _token = 'BBUS-uAKMxSdpaA9UpMmtozq2c48ToYZF07';
  static const String _deviceLabel = 'esp32-monitor';
  static const String _datasourceId = '6a190d0602e450e09139538b';
  static const String _baseUrl = 'https://industrial.api.ubidots.com/api/v1.6';

  Future<SensorData> fetchLatestTelemetry() async {
    final url = Uri.parse(
        '$_baseUrl/datasources/$_datasourceId/variables/?token=$_token');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = json['results'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        throw Exception('Device variables list is empty');
      }

      final Map<String, double> variableValues = {};
      for (var result in results) {
        final label = result['label'] as String?;
        final lastValueMap = result['last_value'] as Map<String, dynamic>?;
        if (label != null && lastValueMap != null) {
          variableValues[label] = (lastValueMap['value'] ?? 0.0).toDouble();
        }
      }

      return SensorData(
        temperature: variableValues['temperature'] ?? 0.0,
        humidity: variableValues['humidity'] ?? 0.0,
        lumen: variableValues['lumen'] ?? 0.0,
        tempBmp: variableValues['temp_bmp'] ?? 0.0,
        pressure: variableValues['pressure'] ?? 0.0,
        altitude: variableValues['altitude'] ?? 0.0,
        powerPid: variableValues['power_pid'] ?? 0.0,
        timestamp: DateTime.now(),
      );
    } else {
      throw HttpException('HTTP Error ${response.statusCode}: ${response.body}',
          response.statusCode);
    }
  }

  Future<List<HistoricalValue>> fetchHistory(
      String variableLabel, DateTime start, DateTime end) async {
    final int startMs = start.millisecondsSinceEpoch;
    final int endMs = end.millisecondsSinceEpoch;

    final url = Uri.parse(
        '$_baseUrl/devices/$_deviceLabel/$variableLabel/values/?token=$_token&start=$startMs&end=$endMs&page_size=2000');

    final response = await http.get(url).timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = json['results'] as List<dynamic>? ?? [];

      return results
          .map((item) => HistoricalValue.fromJson(item))
          .toList()
          .reversed
          .toList();
    } else {
      throw HttpException('HTTP Error ${response.statusCode}: ${response.body}',
          response.statusCode);
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, this.statusCode);

  @override
  String toString() => message;
}
