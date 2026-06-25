import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/incubator_provider.dart';

class EggProgressRing extends StatelessWidget {
  final int currentDay;
  final double percent;
  final String phase;
  final String systemHealth;
  final Color healthColor;

  const EggProgressRing({
    super.key,
    required this.currentDay,
    required this.percent,
    required this.phase,
    required this.systemHealth,
    required this.healthColor,
  });

  String _getDayDescription(int day) {
    if (day == 1) return 'Pembentukan sel pertama & sistem saraf dimulai.';
    if (day == 2) return 'Pembentukan pembuluh darah pertama.';
    if (day == 3) return 'Jantung embrio mulai berdetak pertama kali!';
    if (day == 4) return 'Kuncup kaki & sayap mulai terlihat jelas.';
    if (day == 5) return 'Mata mulai terbentuk dan terlihat jelas.';
    if (day == 6) return 'Paruh dan kuku jari kaki mulai terbentuk.';
    if (day == 7) return 'Embrio mulai bergerak aktif di dalam telur.';
    if (day == 8) return 'Bulu-bulu halus mulai tumbuh pada embrio.';
    if (day == 9) return 'Mulut paruh mulai mengeras.';
    if (day == 10) return 'Paruh telah mengeras sepenuhnya & kuku tumbuh.';
    if (day == 11) return 'Embrio bertambah besar, bulu menutup tubuh.';
    if (day == 12) return 'Anak ayam mulai minum cairan ketuban.';
    if (day == 13) return 'Kaki & cakar mengeras, sisik mulai tumbuh.';
    if (day == 14) return 'Kepala anak ayam bergerak memutar ke ujung tumpul.';
    if (day == 15) return 'Organ pencernaan embrio telah terbentuk sempurna.';
    if (day == 16) return 'Albumin terserap habis, tubuh mengisi ruang.';
    if (day == 17) return 'Persiapan menetas, paruh mendekati kantung udara.';
    if (day == 18) return 'Kuning telur diserap sebagai cadangan makanan.';
    if (day == 19) return 'Mulai mematuk kantung udara (Internal Pipping).';
    if (day == 20) return 'Retakan pertama pada cangkang (External Pipping)!';
    if (day == 21) return 'Saatnya menetas! Selamat datang anak ayam baru!';
    return 'Proses inkubasi sedang berjalan...';
  }

  void _showCustomDayDialog(BuildContext context, IncubatorProvider provider) {
    final controller = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_calendar_rounded, color: AppColors.humidAccent),
              SizedBox(width: 10),
              Text(
                'Mulai Hari Custom',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan hari keberapa Anda ingin memulai siklus inkubasi ini (1 - 21):',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  hintText: 'Misal: 5',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.humidAccent, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final input = controller.text.trim();
                final day = int.tryParse(input);
                if (day != null && day >= 1 && day <= 21) {
                  final startDate = DateTime.now().subtract(Duration(days: day - 1));
                  provider.setIncubationStartDate(startDate);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan angka valid antara 1 sampai 21'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.humidAccent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Mulai', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showStopConfirmationDialog(BuildContext context, IncubatorProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              SizedBox(width: 10),
              Text(
                'Hentikan Inkubasi?',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin mematikan dan mereset siklus inkubasi? Perhitungan hari berjalan akan dihapus.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setIncubationStartDate(null);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, Hentikan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IncubatorProvider>();
    final isActive = currentDay > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: isActive ? healthColor.withValues(alpha: 0.04) : Colors.transparent,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 210,
              height: 210,
              child: Stack(
                children: [
                  // Outer glowing effect when active
                  if (isActive)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: healthColor.withValues(alpha: 0.12),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Background circular path
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Progress indicator
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: isActive ? (percent / 100) : 0.0,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isActive ? healthColor : AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Central interactive area
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (isActive) {
                              _showStopConfirmationDialog(context, provider);
                            } else {
                              provider.setIncubationStartDate(DateTime.now());
                            }
                          },
                          splashColor: isActive
                              ? AppColors.danger.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isActive) ...[
                                  Icon(
                                    Icons.egg_rounded,
                                    color: healthColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Hari ke-$currentDay',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      _getDayDescription(currentDay),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 9,
                                        height: 1.3,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.border.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.success,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'MULAI',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Ketuk untuk Inkubasi',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isActive ? phase : 'Inkubator Nonaktif',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? healthColor : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isActive ? 'Status Sistem: $systemHealth' : 'Sistem Siap',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (!isActive) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showCustomDayDialog(context, provider),
              icon: const Icon(Icons.edit_calendar_rounded, size: 16),
              label: const Text('Lupa Mulai? Set Hari Awal'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.humidAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
