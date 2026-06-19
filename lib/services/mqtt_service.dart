// lib/services/mqtt_service.dart
// Diganti jadi REST API polling (HTTP) karena port MQTT 1883 diblokir jaringan

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class MqttService extends ChangeNotifier {
  static const String _token       = 'BBUS-uAKMxSdpaA9UpMmtozq2c48ToYZF07';
  static const String _deviceLabel = 'esp32-monitor';
  static const String _baseUrl     = 'https://industrial.api.ubidots.com/api/v1.6';

  // Polling setiap 30 detik (ESP32 kirim tiap 5 menit, 30 detik cukup responsif)
  static const Duration _pollInterval = Duration(seconds: 30);

  Timer? _timer;
  bool _isConnected = false;
  SensorData? _latestData;
  final List<SensorData> _history = [];
  String _statusMessage = 'Belum terhubung';

  bool get isConnected => _isConnected;
  SensorData? get latestData => _latestData;
  List<SensorData> get history => List.unmodifiable(_history);
  String get statusMessage => _statusMessage;

  Future<void> connect() async {
    _statusMessage = 'Menghubungkan ke Ubidots...';
    notifyListeners();

    // Fetch langsung sekali, lalu mulai polling
    await _fetchData();

    _timer = Timer.periodic(_pollInterval, (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      // Fetch semua variable sekaligus dari device
      final url = Uri.parse('$_baseUrl/devices/$_deviceLabel/?token=$_token');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Ambil last_value dari masing-masing variable
        final temperature = await _getLastValue('temperature');
        final humidity    = await _getLastValue('humidity');
        final lumen       = await _getLastValue('lumen');
        final tempBmp     = await _getLastValue('temp_bmp');
        final pressure    = await _getLastValue('pressure');
        final altitude    = await _getLastValue('altitude');

        final data = SensorData(
          temperature: temperature,
          humidity:    humidity,
          lumen:       lumen,
          tempBmp:     tempBmp,
          pressure:    pressure,
          altitude:    altitude,
          timestamp:   DateTime.now(),
        );

        _latestData = data;
        _isConnected = true;
        _statusMessage = 'Update: ${DateTime.now().toString().substring(11, 19)}';

        _history.add(data);
        if (_history.length > 20) _history.removeAt(0);

        notifyListeners();
      } else {
        _statusMessage = 'HTTP Error: ${response.statusCode}';
        debugPrint('Response: ${response.body}');
        notifyListeners();
      }
    } on TimeoutException {
      _statusMessage = 'Timeout - cek koneksi internet';
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error: $e';
      _isConnected = false;
      debugPrint('Fetch error: $e');
      notifyListeners();
    }
  }

  Future<double> _getLastValue(String variable) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/variables/$variable/values/?token=$_token&page_size=1&device=$_deviceLabel');
      // Pakai endpoint last value yang lebih efisien
      final url2 = Uri.parse(
          '$_baseUrl/devices/$_deviceLabel/$variable/lv/?token=$_token');
      final response = await http.get(url2).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return double.tryParse(response.body.trim()) ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error get $variable: $e');
    }
    return 0.0;
  }

  void disconnect() {
    _timer?.cancel();
    _timer = null;
    _isConnected = false;
    _statusMessage = 'Terputus';
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}