import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Badge colorido por status — translucent background, semantic text color
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configs[status] ?? _configs['default']!;
    final color = config['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static final _configs = <String, Map<String, Object>>{
    'ativo':        {'color': AppColors.success,       'label': 'ATIVO'},
    'ativa':        {'color': AppColors.info,          'label': 'ATIVA'},
    'ao_vivo':      {'color': AppColors.success,       'label': 'AO VIVO'},
    'reservada':    {'color': AppColors.warning,       'label': 'RESERVADA'},
    'enviado':      {'color': AppColors.warning,       'label': 'ENVIADO'},
    'negociacao':   {'color': AppColors.info,          'label': 'NEGOCIAÇÃO'},
    'inadimplente': {'color': AppColors.danger,        'label': 'INADIMPLENTE'},
    'recomendacao': {'color': AppColors.lilac,         'label': 'RECOMENDAÇÃO'},
    'disponivel':   {'color': AppColors.gray400,       'label': 'DISPONÍVEL'},
    'manutencao':   {'color': AppColors.danger,        'label': 'MANUTENÇÃO'},
    'pendente':     {'color': AppColors.warning,       'label': 'PENDENTE'},
    'aprovada':     {'color': AppColors.success,       'label': 'APROVADA'},
    'recusada':     {'color': AppColors.danger,        'label': 'RECUSADA'},
    'encerrada':    {'color': AppColors.gray400,       'label': 'ENCERRADA'},
    'pago':         {'color': AppColors.success,       'label': 'PAGO'},
    'vencido':      {'color': AppColors.danger,        'label': 'VENCIDO'},
    'suspenso':     {'color': AppColors.danger,        'label': 'SUSPENSO'},
    'default':      {'color': AppColors.gray400,       'label': 'N/A'},
  };
}
