import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';

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
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.bgCard,
          side: BorderSide(
            color: isActive ? AppColors.primary : AppColors.borderLight,
          ),
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isActive ? AppColors.bgCard : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
