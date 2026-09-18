import "package:flutter/material.dart";
import "../models/locker_model.dart";
import "../theme/app_theme.dart";

class CompartmentBox extends StatelessWidget {
  final Compartment compartment;
  final bool isSelected;
  final VoidCallback? onTap;

  const CompartmentBox({
    super.key,
    required this.compartment,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHot = compartment.type == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;
    final isAvailable = compartment.isAvailable;

    Color borderColor;
    Color bgColor;
    if (!isAvailable) {
      borderColor = AppColors.border;
      bgColor = const Color(0xFFF1F5F9);
    } else if (isSelected) {
      borderColor = accentColor;
      bgColor = accentColor.withOpacity(0.08);
    } else {
      borderColor = AppColors.border;
      bgColor = Colors.white;
    }

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  compartment.id,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isAvailable
                        ? (isSelected ? accentColor : AppColors.textPrimary)
                        : AppColors.textMuted,
                  ),
                ),
                Icon(
                  !isAvailable
                      ? Icons.lock_outline_rounded
                      : (isSelected
                          ? Icons.check_circle_rounded
                          : Icons.lock_open_rounded),
                  size: 15,
                  color: !isAvailable
                      ? AppColors.textMuted
                      : (isSelected ? accentColor : AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isHot ? Icons.whatshot : Icons.ac_unit,
                  size: 11,
                  color: isAvailable ? accentColor : AppColors.textMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  '${compartment.currentTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isAvailable ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: !isAvailable
                    ? const Color(0xFFE2E8F0)
                    : (isSelected
                        ? accentColor.withOpacity(0.15)
                        : const Color(0xFFDCFCE7)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                !isAvailable ? 'Terisi' : (isSelected ? 'Dipilih' : 'Tersedia'),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: !isAvailable
                      ? AppColors.textMuted
                      : (isSelected ? accentColor : const Color(0xFF15803D)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
