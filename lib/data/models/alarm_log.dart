class AlarmLog {
  final DateTime timestamp;
  final String title;
  final String description;
  final double value;
  final String type;

  AlarmLog({
    required this.timestamp,
    required this.title,
    required this.description,
    required this.value,
    required this.type,
  });
}
