import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/sensor_data.dart';

class InsightCard extends StatelessWidget {
  final SensorData? latestData;
  final int incubationDay;

  const InsightCard({
    super.key,
    required this.latestData,
    required this.incubationDay,
  });

  List<String> _generateInsights() {
    if (latestData == null) {
      return ['Menghubungkan ke sensor... Mengumpulkan metrik lingkungan.'];
    }

    final insights = <String>[];
    final temp = latestData!.temperature;
    final humid = latestData!.humidity;
    final tempBmp = latestData!.tempBmp;

    if (incubationDay <= 18) {
      if (temp < AppThresholds.minTemp) {
        insights.add(
            'Hari ke-$incubationDay: Suhu dingin. Naikkan suhu ruang atau kurangi ventilasi udara agar pemanas bekerja efisien.');
      } else if (temp > AppThresholds.maxTemp) {
        insights.add(
            'Hari ke-$incubationDay: Suhu terlalu hangat. Periksa apakah ventilasi tersumbat atau jika kipas pendingin mengalami kendala.');
      } else {
        insights.add(
            'Hari ke-$incubationDay: Kondisi suhu optimal untuk fase inkubasi awal. Pastikan pemutaran telur (turning) aktif setiap 3 jam.');
      }

      if (humid < AppThresholds.minHumid) {
        insights.add(
            'Kelembapan rendah ($humid%). Tambahkan air hangat di baki kelembapan inkubator untuk menaikkan kadar kelembapan.');
      } else if (humid > AppThresholds.maxHumid) {
        insights.add(
            'Kelembapan tinggi ($humid%). Buka sedikit ventilasi udara untuk menurunkan penguapan air.');
      }
    } else {
      final targetMinTemp = 36.8;
      final targetMaxTemp = 37.8;
      final targetMinHumid = 70.0;
      final targetMaxHumid = 80.0;

      insights.add(
          'Fase Hatching (Hari $incubationDay dari 21). Hentikan pemutaran telur (turning) secara manual agar embrio dapat memosisikan diri.');

      if (temp < targetMinTemp) {
        insights.add(
            'Suhu terlalu rendah untuk fase hatching. Naikkan intensitas pemanas sedikit demi keselamatan embrio.');
      } else if (temp > targetMaxTemp) {
        insights.add(
            'Suhu agak tinggi untuk fase hatching. Fase menetas memerlukan suhu sedikit lebih sejuk (${targetMinTemp}-${targetMaxTemp}°C).');
      }

      if (humid < targetMinHumid) {
        insights.add(
            'Kelembapan kritis! Naikkan kelembapan hingga $targetMinHumid-$targetMaxHumid% agar cangkang telur melunak sehingga mempermudah anak ayam memecah cangkang.');
      } else {
        insights.add(
            'Kelembapan optimal untuk fase hatching. Menjaga membran cangkang tetap basah.');
      }
    }

    final tempDiff = (temp - tempBmp).abs();
    if (tempDiff > 1.8) {
      insights.add(
          'Sensor Alert: Perbedaan suhu DHT22 ($temp°C) & BMP280 ($tempBmp°C) terdeteksi tinggi ($tempDiff°C). Kemungkinan ada ketidakrataan distribusi panas di dalam box.');
    }

    if (insights.isEmpty) {
      insights.add(
          'Seluruh parameter lingkungan optimal. Sistem bekerja dengan stabil. Terus pantau status secara berkala.');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: AppColors.lightAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Insight & Rekomendasi AI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: insights.map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0, right: 8.0),
                      child: Icon(
                        Icons.arrow_right_rounded,
                        color: AppColors.lightAccent,
                        size: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
