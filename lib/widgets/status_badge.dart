import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge colorido por status
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configs[status] ?? _configs['default']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config['color'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config['label'] as String,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  static const _configs = <String, Map<String, Object>>{
    'ativo':         {'color': AppColors.success,  'label': 'ATIVO'},
    'ao_vivo':       {'color': AppColors.success,  'label': 'AO VIVO'},
    'enviado':       {'color': AppColors.warning,  'label': 'ENVIADO'},
    'negociacao':    {'color': AppColors.info,     'label': 'NEGOCIAÇÃO'},
    'inadimplente':  {'color': AppColors.danger,   'label': 'INADIMPLENTE'},
    'recomendacao':  {'color': AppColors.lilac,    'label': 'RECOMENDAÇÃO'},
    'disponivel':    {'color': Color(0xFF9E9E9E),  'label': 'DISPONÍVEL'},
    'pendente':      {'color': AppColors.warning,  'label': 'PENDENTE'},
    'pago':          {'color': AppColors.success,  'label': 'PAGO'},
    'vencido':       {'color': AppColors.danger,   'label': 'VENCIDO'},
    'suspenso':      {'color': AppColors.danger,   'label': 'SUSPENSO'},
    'default':       {'color': Color(0xFF9E9E9E),  'label': 'N/A'},
  };
}
