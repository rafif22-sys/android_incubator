import 'package:flutter/material.dart';
import '../data/models/historical_value.dart';
import '../data/services/ubidots_service.dart';

enum Timeframe { last24h, last7d, last30d, last1y }

class MetricConfig {
  final String label;
  final String displayName;
  final String unit;
  final Color color;
  final IconData icon;

  const MetricConfig({
    required this.label,
    required this.displayName,
    required this.unit,
    required this.color,
    required this.icon,
  });
}

class HistoryProvider extends ChangeNotifier {
  final UbidotsService _service = UbidotsService();

  Timeframe _selectedTimeframe = Timeframe.last24h;
  int _selectedMetricIndex = 0;

  List<HistoricalValue> _rawHistory = [];
  List<HistoricalValue> _displayHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  final List<MetricConfig> metrics = const [
    MetricConfig(
      label: 'temperature',
      displayName: 'Suhu Inkubator',
      unit: '°C',
      color: Color(0xFFEF4444),
      icon: Icons.thermostat_rounded,
    ),
    MetricConfig(
      label: 'humidity',
      displayName: 'Kelembapan',
      unit: '%',
      color: Color(0xFF06B6D4),
      icon: Icons.water_drop_rounded,
    ),
    MetricConfig(
      label: 'lumen',
      displayName: 'Cahaya (LDR)',
      unit: 'lux',
      color: Color(0xFFF59E0B),
      icon: Icons.wb_sunny_rounded,
    ),
    MetricConfig(
      label: 'temp_bmp',
      displayName: 'Suhu BMP280',
      unit: '°C',
      color: Color(0xFFF97316),
      icon: Icons.device_thermostat_rounded,
    ),
    MetricConfig(
      label: 'pressure',
      displayName: 'Tekanan Udara',
      unit: 'hPa',
      color: Color(0xFF3B82F6),
      icon: Icons.air_rounded,
    ),
    MetricConfig(
      label: 'altitude',
      displayName: 'Ketinggian',
      unit: 'm',
      color: Color(0xFF10B981),
      icon: Icons.terrain_rounded,
    ),
  ];

  Timeframe get selectedTimeframe => _selectedTimeframe;
  int get selectedMetricIndex => _selectedMetricIndex;
  MetricConfig get activeMetric => metrics[_selectedMetricIndex];
  List<HistoricalValue> get history => _displayHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> setTimeframe(Timeframe timeframe) async {
    if (_selectedTimeframe == timeframe &&
        _rawHistory.isNotEmpty &&
        _errorMessage == null) return;
    _selectedTimeframe = timeframe;
    await fetchHistory();
  }

  Future<void> setMetricIndex(int index) async {
    if (_selectedMetricIndex == index &&
        _rawHistory.isNotEmpty &&
        _errorMessage == null) return;
    _selectedMetricIndex = index;
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      late DateTime startDate;

      switch (_selectedTimeframe) {
        case Timeframe.last24h:
          startDate = now.subtract(const Duration(hours: 24));
          break;
        case Timeframe.last7d:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case Timeframe.last30d:
          startDate = now.subtract(const Duration(days: 30));
          break;
        case Timeframe.last1y:
          startDate = now.subtract(const Duration(days: 365));
          break;
      }

      final rawData =
          await _service.fetchHistory(activeMetric.label, startDate, now);
      _rawHistory = rawData;

      int maxPoints = 120;
      if (_selectedTimeframe == Timeframe.last7d) maxPoints = 90;
      if (_selectedTimeframe == Timeframe.last30d) maxPoints = 80;
      if (_selectedTimeframe == Timeframe.last1y) maxPoints = 100;

      _displayHistory = _downsample(rawData, maxPoints);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Gagal memuat grafik historis: ${e.toString().split(':').last.trim()}';
      _displayHistory = [];
      notifyListeners();
    }
  }

  List<HistoricalValue> _downsample(
      List<HistoricalValue> rawData, int maxPoints) {
    if (rawData.length <= maxPoints) return rawData;

    final double interval = rawData.length / maxPoints;
    final List<HistoricalValue> result = [];

    for (int i = 0; i < maxPoints; i++) {
      final int index = (i * interval).floor();
      if (index < rawData.length) {
        result.add(rawData[index]);
      }
    }

    if (result.last.timestamp != rawData.last.timestamp) {
      result[result.length - 1] = rawData.last;
    }

    return result;
  }
}
