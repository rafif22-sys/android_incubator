class HistoricalValue {
  final DateTime timestamp;
  final double value;

  HistoricalValue({
    required this.timestamp,
    required this.value,
  });

  factory HistoricalValue.fromJson(Map<String, dynamic> json) {
    final int tsMs = json['timestamp'] ?? 0;
    return HistoricalValue(
      timestamp: DateTime.fromMillisecondsSinceEpoch(tsMs).toLocal(),
      value: (json['value'] ?? 0.0).toDouble(),
    );
  }
}
