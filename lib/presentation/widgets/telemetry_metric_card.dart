import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class TelemetryMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;

  const TelemetryMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: AppTypography.heading1.copyWith(
                          color: AppColors.textHigh,
                          fontSize: 18,
                        ),
                      ),
                      if (subValue != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            subValue!,
                            style: AppTypography.caption.copyWith(
                              color: accentColor,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
