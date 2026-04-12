import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
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
          selectedColor: context.colors.primary,
          backgroundColor: context.colors.cardBackground,
          side: BorderSide(
            color:
                isActive ? context.colors.primary : context.colors.divider,
          ),
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isActive ? context.colors.cardBackground : context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
