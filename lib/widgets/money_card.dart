import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MoneyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FATURAMENTO DO MÊS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _AnimatedMoneyText(
              value: total,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabelValue('FAT BRUTO', bruto),
                _buildLabelValue('FAT LÍQUIDO', liquido),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        _AnimatedMoneyText(
          value: value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AnimatedMoneyText extends StatelessWidget {
  final double value;
  final TextStyle style;

  const _AnimatedMoneyText({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          'R\$ ${val.toStringAsFixed(2).replaceAll('.', ',')}',
          style: style,
        );
      },
    );
  }
}
