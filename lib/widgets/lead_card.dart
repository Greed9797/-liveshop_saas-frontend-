import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import 'action_button.dart';

/// Card de lead com botão "PEGAR LEAD"
class LeadCard extends StatelessWidget {
  final Map<String, dynamic> lead;
  final VoidCallback? onPegar;
  const LeadCard({super.key, required this.lead, this.onPegar});

  @override
  Widget build(BuildContext context) {
    final isNovo = lead['novo'] == true;
    final fat = (lead['fat_estimado'] as num?)?.toInt() ?? 0;
    final fatFormatted = fat.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.compactPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(lead['nome'] as String,
                        style: AppTypography.bodyMedium),
                      if (isNovo) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: const Text('NOVO',
                            style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${lead['nicho']} • ${lead['cidade']}',
                    style: AppTypography.caption),
                  Text('Fat. est.: R\$ $fatFormatted',
                    style: AppTypography.caption),
                ],
              ),
            ),
            ActionButton(
              label: 'PEGAR LEAD',
              onPressed: onPegar,
              icon: Icons.bolt_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
