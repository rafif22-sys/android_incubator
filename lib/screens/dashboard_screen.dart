// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/mqtt_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/history_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        final data = mqtt.latestData;

        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inkubator Monitor',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data != null
                                  ? 'Update: ${DateFormat('HH:mm:ss').format(data.timestamp)}'
                                  : 'Belum ada data',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Connection status chip
                        GestureDetector(
                          onTap: mqtt.isConnected
                              ? null
                              : () => mqtt.connect(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: mqtt.isConnected
                                  ? Colors.greenAccent.withOpacity(0.15)
                                  : Colors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: mqtt.isConnected
                                    ? Colors.greenAccent.withOpacity(0.5)
                                    : Colors.redAccent.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: mqtt.isConnected
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mqtt.isConnected ? 'Live' : 'Tap Hubungkan',
                                  style: TextStyle(
                                    color: mqtt.isConnected
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Status message ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      mqtt.statusMessage,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                // ── Alert banner ──────────────────────────────────────
                if (data != null && data.hasAlert)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.redAccent.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.redAccent, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                [
                                  if (data.isTempAlert)
                                    'Suhu ${data.temperature.toStringAsFixed(1)}°C di luar rentang optimal (37–38.5°C)',
                                  if (data.isHumidAlert)
                                    'Kelembapan ${data.humidity.toStringAsFixed(1)}% di luar rentang optimal (60–70%)',
                                ].join(' • '),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Sensor Cards Grid ─────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate([
                      // DHT22 - Suhu
                      SensorCard(
                        label: 'Suhu Inkubator',
                        value: data != null
                            ? data.temperature.toStringAsFixed(1)
                            : '--',
                        unit: '°C',
                        icon: Icons.thermostat_rounded,
                        color: const Color(0xFFFF6B6B),
                        status: data?.tempStatus,
                        isAlert: data?.isTempAlert ?? false,
                      ),
                      // DHT22 - Kelembapan
                      SensorCard(
                        label: 'Kelembapan',
                        value: data != null
                            ? data.humidity.toStringAsFixed(1)
                            : '--',
                        unit: '%',
                        icon: Icons.water_drop_rounded,
                        color: const Color(0xFF4ECDC4),
                        status: data?.humidityStatus,
                        isAlert: data?.isHumidAlert ?? false,
                      ),
                      // LDR - Cahaya
                      SensorCard(
                        label: 'Cahaya (LDR)',
                        value: data != null
                            ? data.lumen.toStringAsFixed(0)
                            : '--',
                        unit: 'lux',
                        icon: Icons.wb_sunny_rounded,
                        color: const Color(0xFFFFBE0B),
                      ),
                      // BMP280 - Suhu
                      SensorCard(
                        label: 'Suhu BMP280',
                        value: data != null
                            ? data.tempBmp.toStringAsFixed(1)
                            : '--',
                        unit: '°C',
                        icon: Icons.device_thermostat_rounded,
                        color: const Color(0xFFFF9F43),
                      ),
                      // BMP280 - Tekanan
                      SensorCard(
                        label: 'Tekanan Udara',
                        value: data != null
                            ? data.pressure.toStringAsFixed(1)
                            : '--',
                        unit: 'hPa',
                        icon: Icons.air_rounded,
                        color: const Color(0xFFA8DAFF),
                      ),
                      // BMP280 - Altitude
                      SensorCard(
                        label: 'Ketinggian',
                        value: data != null
                            ? data.altitude.toStringAsFixed(1)
                            : '--',
                        unit: 'm',
                        icon: Icons.terrain_rounded,
                        color: const Color(0xFF88D8B0),
                      ),
                    ]),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                  ),
                ),

                // ── Chart ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: SliverToBoxAdapter(
                    child: HistoryChart(history: mqtt.history),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
