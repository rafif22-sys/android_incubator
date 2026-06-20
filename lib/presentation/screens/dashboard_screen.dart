import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/sensor_data.dart';
import '../../providers/incubator_provider.dart';
import '../widgets/egg_progress_ring.dart';
import '../widgets/premium_sensor_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/alarm_log_sheet.dart';
import '../widgets/historical_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncubatorProvider>().connect();
    });
  }

  void _showAlarmHistory(BuildContext context, IncubatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.7,
        child: AlarmLogSheet(
          alarms: provider.alarms,
          onClear: () {
            provider.clearAlarms();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inkubator Pintar',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Sistem Monitoring Real-Time',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<IncubatorProvider>(
            builder: (context, provider, _) {
              final alarmCount = provider.alarms.length;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => _showAlarmHistory(context, provider),
                    ),
                    if (alarmCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$alarmCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<IncubatorProvider>(
        builder: (context, provider, _) {
          final data = provider.latestData;

          if (provider.isLoading && data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16),
                  Text(
                    'Menginisialisasi modul IoT...',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          if (!provider.isConnected && data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_off_rounded,
                          color: AppColors.danger, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Koneksi Cloud Terputus',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: provider.connect,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Hubungkan Ulang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.humidAccent,
            backgroundColor: AppColors.surface,
            onRefresh: provider.refreshLatest,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                if (data != null && data.hasAlert)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.danger, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                [
                                  if (data.isTempAlert)
                                    'Suhu (${data.temperature.toStringAsFixed(1)}°C) keluar batas optimal.',
                                  if (data.isHumidAlert)
                                    'Kelembapan (${data.humidity.toStringAsFixed(1)}%) keluar batas optimal.',
                                ].join(' '),
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      EggProgressRing(
                        currentDay: provider.incubationDay,
                        percent: provider.incubationPercent,
                        phase: provider.incubationPhase,
                        latestData: data,
                        systemHealth: provider.systemHealth,
                        healthColor: provider.healthColor,
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.sensors_rounded,
                              color: AppColors.textSecondary, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Sensor Telemetri',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTelemetryGrid(provider, data),
                      const SizedBox(height: 16),
                      InsightCard(
                        latestData: data,
                        incubationDay: provider.incubationDay,
                      ),
                      const SizedBox(height: 16),
                      const HistoricalChart(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTelemetryGrid(IncubatorProvider provider, SensorData? data) {
    final tempHistory =
        provider.recentDataPoints.map((d) => d.temperature).toList();
    final humidHistory =
        provider.recentDataPoints.map((d) => d.humidity).toList();
    final lumenHistory = provider.recentDataPoints.map((d) => d.lumen).toList();
    final tempBmpHistory =
        provider.recentDataPoints.map((d) => d.tempBmp).toList();
    final pressHistory =
        provider.recentDataPoints.map((d) => d.pressure).toList();
    final altHistory =
        provider.recentDataPoints.map((d) => d.altitude).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PremiumSensorCard(
                label: 'Suhu Utama',
                value:
                    data != null ? data.temperature.toStringAsFixed(1) : '--',
                unit: '°C',
                icon: Icons.thermostat_rounded,
                color: AppColors.tempAccent,
                status: data?.tempStatus,
                isAlert: data?.isTempAlert ?? false,
                sparklinePoints: tempHistory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumSensorCard(
                label: 'Kelembapan',
                value: data != null ? data.humidity.toStringAsFixed(1) : '--',
                unit: '%',
                icon: Icons.water_drop_rounded,
                color: AppColors.humidAccent,
                status: data?.humidityStatus,
                isAlert: data?.isHumidAlert ?? false,
                sparklinePoints: humidHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PremiumSensorCard(
                label: 'Cahaya (LDR)',
                value: data != null ? data.lumen.toStringAsFixed(0) : '--',
                unit: 'lux',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.lightAccent,
                sparklinePoints: lumenHistory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumSensorCard(
                label: 'Suhu BMP280',
                value: data != null ? data.tempBmp.toStringAsFixed(1) : '--',
                unit: '°C',
                icon: Icons.device_thermostat_rounded,
                color: AppColors.heaterAccent,
                sparklinePoints: tempBmpHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PremiumSensorCard(
                label: 'Tekanan Udara',
                value: data != null ? data.pressure.toStringAsFixed(1) : '--',
                unit: 'hPa',
                icon: Icons.air_rounded,
                color: AppColors.pressureAccent,
                sparklinePoints: pressHistory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumSensorCard(
                label: 'Ketinggian',
                value: data != null ? data.altitude.toStringAsFixed(1) : '--',
                unit: 'm',
                icon: Icons.terrain_rounded,
                color: AppColors.altitudeAccent,
                sparklinePoints: altHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
