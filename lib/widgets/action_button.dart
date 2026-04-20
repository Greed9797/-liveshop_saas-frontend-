import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Botão de ação padrão do sistema — com profundidade 3D (elevation,
/// sombra colorida, hover states).
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
        icon: icon != null
            ? Icon(icon, size: 16, color: btnColor)
            : const SizedBox.shrink(),
        label: Text(label,
            style: TextStyle(
                color: btnColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3),
            overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: btnColor, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          animationDuration: const Duration(milliseconds: 150),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return btnColor.withValues(alpha: 0.06);
            }
            return null;
          }),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, size: 16, color: Colors.white)
          : const SizedBox.shrink(),
      label: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3),
          overflow: TextOverflow.ellipsis),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: btnColor.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        animationDuration: const Duration(milliseconds: 150),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 1;
          if (states.contains(WidgetState.hovered)) return 6;
          return 2;
        }),
      ),
    );
  }
}
