import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          gradient: const LinearGradient(
            colors: [AppColors.primaryOrange, AppColors.orange600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppColors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('FATURAMENTO TOTAL',
                        style: AppTypography.caption.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white.withValues(alpha: 0.8))),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: () => ref
                      .read(moneyVisibilityProvider.notifier)
                      .state = !isVisible,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                isVisible
                    ? 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}'
                    : 'R\$ •••••••',
                style: AppTypography.heroNumber.copyWith(color: AppColors.white),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SubValue(
                    label: 'FATURAMENTO BRUTO',
                    value: bruto,
                    isVisible: isVisible,
                  ),
                ),
                Container(
                    width: 1,
                    height: 40,
                    color: AppColors.white.withValues(alpha: 0.2)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    child: _SubValue(
                      label: 'FATURAMENTO LÍQUIDO',
                      value: liquido,
                      isVisible: isVisible,
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

  const _SubValue({
    required this.label,
    required this.value,
    required this.isVisible,
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
              letterSpacing: 0.5,
              color: AppColors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            isVisible
                ? 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}'
                : 'R\$ •••••',
            style: AppTypography.h3
                .copyWith(color: AppColors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
