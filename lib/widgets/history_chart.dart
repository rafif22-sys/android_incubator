// lib/widgets/history_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';

class HistoryChart extends StatefulWidget {
  final List<SensorData> history;

  const HistoryChart({super.key, required this.history});

  @override
  State<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart> {
  // 0=Suhu DHT, 1=Kelembapan, 2=Suhu BMP, 3=Tekanan
  int _selectedMetric = 0;

  final List<_MetricConfig> _metrics = [
    _MetricConfig('Suhu (DHT22)', '°C', const Color(0xFFFF6B6B)),
    _MetricConfig('Kelembapan',   '%',  const Color(0xFF4ECDC4)),
    _MetricConfig('Suhu BMP280',  '°C', const Color(0xFFFFBE0B)),
    _MetricConfig('Cahaya',       'lx', const Color(0xFFA8DAFF)),
  ];

  List<FlSpot> get _spots {
    final data = widget.history;
    return List.generate(data.length, (i) {
      final d = data[i];
      final y = switch (_selectedMetric) {
        0 => d.temperature,
        1 => d.humidity,
        2 => d.tempBmp,
        3 => d.lumen,
        _ => 0.0,
      };
      return FlSpot(i.toDouble(), y);
    });
  }

  @override
  Widget build(BuildContext context) {
    final metric = _metrics[_selectedMetric];
    final spots  = _spots;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grafik History',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.history.length} data point',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metric selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_metrics.length, (i) {
                final selected = i == _selectedMetric;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMetric = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? _metrics[i].color.withOpacity(0.25)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? _metrics[i].color
                            : Colors.white10,
                      ),
                    ),
                    child: Text(
                      _metrics[i].label,
                      style: TextStyle(
                        color: selected
                            ? _metrics[i].color
                            : Colors.white38,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Chart
          if (spots.length < 2)
            SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Menunggu data masuk...\n(data dikirim setiap 5 menit)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: null,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toStringAsFixed(0)} ${metric.unit}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (spots.length / 4).ceilToDouble(),
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= widget.history.length) {
                            return const SizedBox();
                          }
                          final t = widget.history[idx].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: metric.color,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: metric.color,
                          strokeWidth: 1.5,
                          strokeColor: const Color(0xFF1E2A3A),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            metric.color.withOpacity(0.25),
                            metric.color.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricConfig {
  final String label;
  final String unit;
  final Color  color;
  const _MetricConfig(this.label, this.unit, this.color);
}
