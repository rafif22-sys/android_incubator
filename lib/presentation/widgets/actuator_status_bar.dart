import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ActuatorStatusBar extends StatelessWidget {
  final bool isConnected;
  final String statusMessage;
  final VoidCallback onReconnect;

  const ActuatorStatusBar({
    super.key,
    required this.isConnected,
    required this.statusMessage,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: isConnected ? null : onReconnect,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            isConnected ? AppColors.success : AppColors.danger,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isConnected
                                    ? AppColors.success
                                    : AppColors.danger)
                                .withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Koneksi Live' : 'Terputus - Tap Reconnect',
                      style: TextStyle(
                        color: isConnected
                            ? AppColors.textPrimary
                            : AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                statusMessage,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
