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

  void _showThresholdSettingsSheet(BuildContext context, IncubatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: _ThresholdSettingsForm(provider: provider),
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
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
            onPressed: () => _showThresholdSettingsSheet(context, context.read<IncubatorProvider>()),
          ),
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
                if (data != null && data.hasAlert(provider.minTemp, provider.maxTemp, provider.minHumid, provider.maxHumid))
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
                                  if (data.isTempAlert(provider.minTemp, provider.maxTemp))
                                    'Suhu (${data.temperature.toStringAsFixed(1)}°C) keluar batas optimal.',
                                  if (data.isHumidAlert(provider.minHumid, provider.maxHumid))
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
                        minTemp: provider.minTemp,
                        maxTemp: provider.maxTemp,
                        minHumid: provider.minHumid,
                        maxHumid: provider.maxHumid,
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
                status: data?.tempStatus(provider.minTemp, provider.maxTemp),
                isAlert: data?.isTempAlert(provider.minTemp, provider.maxTemp) ?? false,
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
                status: data?.humidityStatus(provider.minHumid, provider.maxHumid),
                isAlert: data?.isHumidAlert(provider.minHumid, provider.maxHumid) ?? false,
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

class _ThresholdSettingsForm extends StatefulWidget {
  final IncubatorProvider provider;

  const _ThresholdSettingsForm({required this.provider});

  @override
  State<_ThresholdSettingsForm> createState() => _ThresholdSettingsFormState();
}

class _ThresholdSettingsFormState extends State<_ThresholdSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHumidController;
  late TextEditingController _maxHumidController;

  @override
  void initState() {
    super.initState();
    _minTempController = TextEditingController(text: widget.provider.minTemp.toString());
    _maxTempController = TextEditingController(text: widget.provider.maxTemp.toString());
    _minHumidController = TextEditingController(text: widget.provider.minHumid.toString());
    _maxHumidController = TextEditingController(text: widget.provider.maxHumid.toString());
  }

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumidController.dispose();
    _maxHumidController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final minT = double.parse(_minTempController.text);
      final maxT = double.parse(_maxTempController.text);
      final minH = double.parse(_minHumidController.text);
      final maxH = double.parse(_maxHumidController.text);

      widget.provider.updateThresholds(minT, maxT, minH, maxH);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text('Ambang batas berhasil diperbarui!'),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.tune_rounded, color: AppColors.humidAccent),
                SizedBox(width: 10),
                Text(
                  'Pengaturan Ambang Batas',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Sesuaikan batas aman suhu (°C) dan kelembapan (%) untuk inkubator.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildSectionHeader('Suhu (°C)', Icons.thermostat_rounded, AppColors.tempAccent),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Min Suhu',
                            controller: _minTempController,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Wajib diisi';
                              final numVal = double.tryParse(val);
                              if (numVal == null) return 'Harus angka';
                              if (numVal < 0 || numVal > 100) return '0 - 100';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'Max Suhu',
                            controller: _maxTempController,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Wajib diisi';
                              final numVal = double.tryParse(val);
                              if (numVal == null) return 'Harus angka';
                              final minVal = double.tryParse(_minTempController.text);
                              if (minVal != null && numVal <= minVal) {
                                return 'Batas max harus > min';
                              }
                              if (numVal < 0 || numVal > 100) return '0 - 100';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Kelembapan (%)', Icons.water_drop_rounded, AppColors.humidAccent),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Min Lembap',
                            controller: _minHumidController,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Wajib diisi';
                              final numVal = double.tryParse(val);
                              if (numVal == null) return 'Harus angka';
                              if (numVal < 0 || numVal > 100) return '0 - 100';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'Max Lembap',
                            controller: _maxHumidController,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Wajib diisi';
                              final numVal = double.tryParse(val);
                              if (numVal == null) return 'Harus angka';
                              final minVal = double.tryParse(_minHumidController.text);
                              if (minVal != null && numVal <= minVal) {
                                return 'Batas max harus > min';
                              }
                              if (numVal < 0 || numVal > 100) return '0 - 100';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.humidAccent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Pengaturan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        floatingLabelStyle: const TextStyle(color: AppColors.humidAccent, fontSize: 12),
        fillColor: AppColors.surfaceElevated,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.humidAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 10),
      ),
    );
  }
}
