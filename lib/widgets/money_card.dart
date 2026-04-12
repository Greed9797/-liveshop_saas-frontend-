import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'money_text.dart';

// StateProvider simples para gerenciar a visibilidade globalmente
final moneyVisibilityProvider = StateProvider<bool>((ref) => false);

class MoneyCard extends ConsumerWidget {
  final double total;
  final double bruto;
  final double liquido;
  final VoidCallback? onTap;

  const MoneyCard({
    super.key,
    required this.total,
    required this.bruto,
    required this.liquido,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(moneyVisibilityProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.md,
          border: Border.all(color: context.colors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FATURAMENTO TOTAL',
                    style: AppTypography.caption.copyWith(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: context.colors.textTertiary,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => ref
                      .read(moneyVisibilityProvider.notifier)
                      .state = !isVisible,
                ),
              ],
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: isVisible
                  ? MoneyText(
                      value: total,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    )
                  : Text(
                      'R\$ •••••••',
                      style: AppTypography.heroNumber.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Divider(color: context.colors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SubValue(
                    label: 'BRUTO',
                    value: bruto,
                    isVisible: isVisible,
                    color: context.colors.success,
                  ),
                ),
                Container(
                    width: 1,
                    height: 36,
                    color: context.colors.divider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    child: _SubValue(
                      label: 'LÍQUIDO',
                      value: liquido,
                      isVisible: isVisible,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubValue extends StatelessWidget {
  final String label;
  final double value;
  final bool isVisible;
  final Color color;

  const _SubValue({
    required this.label,
    required this.value,
    required this.isVisible,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: isVisible
              ? MoneyText(
                  value: value,
                  fontSize: 15,
                  color: color,
                )
              : Text(
                  'R\$ •••••',
                  style: AppTypography.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
        ),
      ],
    );
  }
}
