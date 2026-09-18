import "package:flutter/material.dart";
import "../models/locker_model.dart";
import "../theme/app_theme.dart";

class TemperatureGauge extends StatelessWidget {
  final double currentTemp;
  final double targetTemp;
  final StorageType storageType;
  final double size;

  const TemperatureGauge({
    super.key,
    required this.currentTemp,
    required this.targetTemp,
    required this.storageType,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final isHot = storageType == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHot ? Icons.whatshot_rounded : Icons.ac_unit_rounded,
              color: accentColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTemp.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  '°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Target ${targetTemp.toStringAsFixed(0)}°C',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
