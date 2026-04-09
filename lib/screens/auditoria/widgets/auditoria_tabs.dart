import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class AuditoriaTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const AuditoriaTabs({
    super.key,
    required this.current,
    required this.onChanged,
  });

  static const tabs = [
    ('novos', 'Novos'),
    ('em_tratativa', 'Em Tratativa'),
    ('finalizados', 'Finalizados'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tabs.map((item) {
        final isActive = current == item.$1;
        return ChoiceChip(
          label: Text(item.$2),
          selected: isActive,
          onSelected: (_) => onChanged(item.$1),
          selectedColor: AppColors.primaryOrange,
          backgroundColor: AppColors.surfaceWhite,
          side: BorderSide(
            color:
                isActive ? AppColors.primaryOrange : AppColors.surfaceDivider,
          ),
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isActive ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
