import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/sensor_data.dart';
import '../data/models/alarm_log.dart';
import '../data/services/ubidots_service.dart';

class IncubatorProvider extends ChangeNotifier {
  final UbidotsService _service = UbidotsService();

  SensorData? _latestData;
  bool _isConnected = false;
  bool _isLoading = false;
  String _statusMessage = 'Belum terhubung';
  Timer? _pollTimer;

  final List<SensorData> _recentDataPoints = [];

  final List<AlarmLog> _alarms = [];

  DateTime _incubationStartDate =
      DateTime.now().subtract(const Duration(days: 11, hours: 5));

  SensorData? get latestData => _latestData;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  List<AlarmLog> get alarms => List.unmodifiable(_alarms);
  List<SensorData> get recentDataPoints => List.unmodifiable(_recentDataPoints);
  DateTime get incubationStartDate => _incubationStartDate;

  int get incubationDay {
    final diff = DateTime.now().difference(_incubationStartDate);
    final days = diff.inDays + 1;
    return days.clamp(1, 21);
  }

  double get incubationPercent {
    final diff = DateTime.now().difference(_incubationStartDate);
    final percent = (diff.inSeconds / (21 * 24 * 3600)) * 100;
    return percent.clamp(0.0, 100.0);
  }

  String get incubationPhase {
    final day = incubationDay;
    if (day >= 1 && day <= 18) {
      return 'Fase Inkubasi (Turning Aktif)';
    } else if (day >= 19 && day <= 21) {
      return 'Fase Hatching (Hentikan Turning)';
    }
    return 'Selesai / Menetas';
  }

  String get systemHealth {
    if (!_isConnected) return 'Offline';
    if (_latestData == null) return 'Menunggu Data';

    final temp = _latestData!.temperature;
    final humid = _latestData!.humidity;

    if (temp < 35.0 || temp > 40.0 || humid < 40.0 || humid > 85.0) {
      return 'Bahaya / Kritis';
    }

    if (_latestData!.hasAlert) {
      return 'Perlu Perhatian';
    }

    return 'Optimal';
  }

  Color get healthColor {
    return switch (systemHealth) {
      'Offline' => AppColors.textMuted,
      'Menunggu Data' => AppColors.warning,
      'Bahaya / Kritis' => AppColors.danger,
      'Perlu Perhatian' => AppColors.warning,
      'Optimal' => AppColors.success,
      _ => AppColors.textMuted,
    };
  }

  Future<void> connect() async {
    if (_pollTimer != null) return;

    _isLoading = true;
    _statusMessage = 'Menghubungkan ke Ubidots...';
    notifyListeners();

    await refreshLatest();

    _isLoading = false;
    notifyListeners();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => refreshLatest());
  }

  void disconnect() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isConnected = false;
    _statusMessage = 'Terputus';
    notifyListeners();
  }

  Future<void> refreshLatest() async {
    try {
      final data = await _service.fetchLatestTelemetry();
      _latestData = data;
      _isConnected = true;
      _statusMessage =
          'Update: ${DateTime.now().toLocal().toString().substring(11, 19)}';

      _recentDataPoints.add(data);
      if (_recentDataPoints.length > 15) {
        _recentDataPoints.removeAt(0);
      }

      _checkAlerts(data);
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _statusMessage = 'Gagal memuat: ${e.toString().split(':').last.trim()}';
      notifyListeners();
    }
  }

  void setIncubationStartDate(DateTime date) {
    _incubationStartDate = date;
    notifyListeners();
  }

  void _checkAlerts(SensorData data) {
    final now = DateTime.now();

    if (data.isTempAlert) {
      final String alertType = data.temperature < AppThresholds.minTemp
          ? 'Suhu Terlalu Dingin'
          : 'Suhu Terlalu Panas';
      final String desc =
          'Suhu ${data.temperature.toStringAsFixed(1)}°C di luar batas optimal (${AppThresholds.minTemp}-${AppThresholds.maxTemp}°C)';

      _logAlarmIfNew('temperature', alertType, desc, data.temperature, now);
    }

    if (data.isHumidAlert) {
      final String alertType = data.humidity < AppThresholds.minHumid
          ? 'Kelembapan Kering'
          : 'Kelembapan Basah';
      final String desc =
          'Kelembapan ${data.humidity.toStringAsFixed(1)}% di luar batas optimal (${AppThresholds.minHumid}-${AppThresholds.maxHumid}%)';

      _logAlarmIfNew('humidity', alertType, desc, data.humidity, now);
    }
  }

  void _logAlarmIfNew(
      String type, String title, String desc, double val, DateTime time) {
    final lastAlarmOfSameType = _alarms.reversed.firstWhere(
      (a) => a.type == type,
      orElse: () => AlarmLog(
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          title: '',
          description: '',
          value: 0.0,
          type: ''),
    );

    final timeDiff = time.difference(lastAlarmOfSameType.timestamp);
    if (timeDiff.inMinutes > 10 || lastAlarmOfSameType.title != title) {
      _alarms.add(AlarmLog(
        timestamp: time,
        title: title,
        description: desc,
        value: val,
        type: type,
      ));

      if (_alarms.length > 50) {
        _alarms.removeAt(0);
      }
    }
  }

  void clearAlarms() {
    _alarms.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
