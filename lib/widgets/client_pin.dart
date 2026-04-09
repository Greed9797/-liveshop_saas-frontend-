import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Pin do mapa por status do cliente
class ClientPin extends StatefulWidget {
  final String status;
  final String nome;
  final VoidCallback? onTap;

  const ClientPin(
      {super.key, required this.status, required this.nome, this.onTap});

  @override
  State<ClientPin> createState() => _ClientPinState();
}

class _ClientPinState extends State<ClientPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  Color get _color => switch (widget.status) {
        'ativo' => AppColors.successGreen,
        'enviado' => AppColors.warningYellow,
        'em_analise' => AppColors.warningYellow,
        'negociacao' => AppColors.infoBlue,
        'inadimplente' => AppColors.dangerRed,
        'recomendacao' => AppColors.infoPurple,
        _ => AppColors.gray400,
      };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulse = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // Pulse animation only for default/critical pins like inadimplente
    if (widget.status == 'inadimplente') {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ],
            ),
            child: Text(
              widget.nome,
              style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ScaleTransition(
            scale: _pulse,
            child: Icon(Icons.location_on_rounded, color: _color, size: 36),
          ),
        ],
      ),
    );
  }
}
