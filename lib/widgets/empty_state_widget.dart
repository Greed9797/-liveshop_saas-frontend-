import 'package:flutter/material.dart';
import '../theme/app_colors_extension.dart';
import '../theme/app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  const EmptyStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
