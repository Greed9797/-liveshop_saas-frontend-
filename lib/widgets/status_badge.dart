import 'package:flutter/material.dart';
import '../design_system/app_components.dart';

/// Badge colorido por status encapsulando a nova semântica da identidade visual
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configs[status] ?? _configs['default']!;
    final type = config['type'] as AppBadgeType;
    return AppBadge(
      label: config['label'] as String,
      type: type,
      showDot: true,
    );
  }

  static final _configs = <String, Map<String, Object>>{
    'ativo':        {'type': AppBadgeType.success,       'label': 'ATIVO'},
    'ativa':        {'type': AppBadgeType.success,       'label': 'ATIVA'},
    'ao_vivo':      {'type': AppBadgeType.success,       'label': 'AO VIVO'},
    'reservada':    {'type': AppBadgeType.warning,       'label': 'RESERVADA'},
    'enviado':      {'type': AppBadgeType.warning,       'label': 'ENVIADO'},
    'negociacao':   {'type': AppBadgeType.warning,       'label': 'NEGOCIAÇÃO'},
    'inadimplente': {'type': AppBadgeType.danger,        'label': 'INADIMPLENTE'},
    'recomendacao': {'type': AppBadgeType.neutral,       'label': 'RECOMENDAÇÃO'},
    'disponivel':   {'type': AppBadgeType.neutral,       'label': 'DISPONÍVEL'},
    'manutencao':   {'type': AppBadgeType.danger,        'label': 'MANUTENÇÃO'},
    'pendente':     {'type': AppBadgeType.warning,       'label': 'PENDENTE'},
    'aprovada':     {'type': AppBadgeType.success,       'label': 'APROVADA'},
    'recusada':     {'type': AppBadgeType.danger,        'label': 'RECUSADA'},
    'encerrada':    {'type': AppBadgeType.neutral,       'label': 'ENCERRADA'},
    'pago':         {'type': AppBadgeType.success,       'label': 'PAGO'},
    'vencido':      {'type': AppBadgeType.danger,        'label': 'VENCIDO'},
    'suspenso':     {'type': AppBadgeType.danger,        'label': 'SUSPENSO'},
    'default':      {'type': AppBadgeType.neutral,       'label': 'N/A'},
  };
}
