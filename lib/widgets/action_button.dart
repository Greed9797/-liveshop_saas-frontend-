import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Botão de ação padrão do sistema
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool outlined;

  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 16, color: btnColor) : const SizedBox.shrink(),
        label: Text(label, style: TextStyle(color: btnColor, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: btnColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 16, color: Colors.white) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
