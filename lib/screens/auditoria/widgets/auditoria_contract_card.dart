import 'package:flutter/material.dart';

import '../../../models/contrato.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import 'auditoria_sla_chip.dart';
import 'auditoria_status_badge.dart';

class AuditoriaContractCard extends StatelessWidget {
  final Contrato contrato;
  final VoidCallback onApprove;
  final VoidCallback onPendencia;
  final VoidCallback onReprovar;
  final VoidCallback onArquivar;

  const AuditoriaContractCard({
    super.key,
    required this.contrato,
    required this.onApprove,
    required this.onPendencia,
    required this.onReprovar,
    required this.onArquivar,
  });

  @override
  Widget build(BuildContext context) {
    final reason = contrato.pendenciaMotivo ?? contrato.reprovacaoMotivo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    contrato.clienteNome ?? 'Cliente sem nome',
                    style: AppTypography.h3,
                  ),
                ),
                AuditoriaStatusBadge(status: contrato.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contrato.clienteCnpj ?? 'CNPJ não informado',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Franqueado: ${contrato.franqueadoNome ?? 'Não informado'}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Ticket: R\$ ${contrato.valorFixo.toStringAsFixed(2)}',
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Comissão: ${contrato.comissaoPct.toStringAsFixed(0)}%',
                  style: AppTypography.bodySmall,
                ),
                AuditoriaSlaChip(hours: contrato.tempoEmEsperaHoras),
              ],
            ),
            if (reason != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(reason, style: AppTypography.bodySmall),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Aprovar'),
                ),
                OutlinedButton.icon(
                  onPressed: onPendencia,
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Pendência'),
                ),
                OutlinedButton.icon(
                  onPressed: onReprovar,
                  icon: const Icon(Icons.block_rounded, size: 16),
                  label: const Text('Reprovar'),
                ),
                TextButton.icon(
                  onPressed: onArquivar,
                  icon: const Icon(Icons.archive_outlined,
                      size: 16, color: AppColors.textSecondary),
                  label: const Text('Arquivar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
