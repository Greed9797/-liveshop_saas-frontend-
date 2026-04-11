import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

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
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        config['label'] as String,
        style: const TextStyle(
            color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  static final _configs = <String, Map<String, Object>>{
    'ativo': {'color': AppColors.success, 'label': 'ATIVO'},
    'ativa': {'color': AppColors.info, 'label': 'ATIVA'},
    'ao_vivo': {'color': AppColors.success, 'label': 'AO VIVO'},
    'reservada': {'color': AppColors.warning, 'label': 'RESERVADA'},
    'enviado': {'color': AppColors.warning, 'label': 'ENVIADO'},
    'negociacao': {'color': AppColors.info, 'label': 'NEGOCIAÇÃO'},
    'inadimplente': {'color': AppColors.danger, 'label': 'INADIMPLENTE'},
    'recomendacao': {'color': AppColors.lilac, 'label': 'RECOMENDAÇÃO'},
    'disponivel': {'color': AppColors.gray400, 'label': 'DISPONÍVEL'},
    'manutencao': {'color': AppColors.danger, 'label': 'MANUTENÇÃO'},
    'pendente': {'color': AppColors.warning, 'label': 'PENDENTE'},
    'aprovada': {'color': AppColors.success, 'label': 'APROVADA'},
    'recusada': {'color': AppColors.danger, 'label': 'RECUSADA'},
    'encerrada': {'color': AppColors.gray400, 'label': 'ENCERRADA'},
    'pago': {'color': AppColors.success, 'label': 'PAGO'},
    'vencido': {'color': AppColors.danger, 'label': 'VENCIDO'},
    'suspenso': {'color': AppColors.danger, 'label': 'SUSPENSO'},
    'default': {'color': AppColors.gray400, 'label': 'N/A'},
  };
}
