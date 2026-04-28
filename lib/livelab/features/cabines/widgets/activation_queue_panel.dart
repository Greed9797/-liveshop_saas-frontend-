import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../cabines_models.dart';

class ActivationQueuePanel extends StatelessWidget {
  const ActivationQueuePanel({super.key, required this.entries});

  final List<QueueEntry> entries;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;

    return Container(
      decoration: BoxDecoration(
        color: t.bgElev1,
        borderRadius: BorderRadius.circular(LlRadius.xl),
        border: Border.all(color: t.border),
        boxShadow: t.shadowCard,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Fila de ativação',
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: t.bgElev2,
                  borderRadius: BorderRadius.circular(LlRadius.pill),
                ),
                child: Text(
                  '${entries.length}',
                  style: TextStyle(
                    color: t.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Contratos aguardando alocação em cabine.',
            style: TextStyle(color: t.textMuted, fontSize: 12),
          ),
          if (entries.isEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Nenhum contrato aguardando alocação.',
              style: TextStyle(
                color: t.textFaint,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...entries.asMap().entries.map(
              (e) => _QueueItem(
                entry: e.value,
                isFirst: e.key == 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({required this.entry, required this.isFirst});

  final QueueEntry entry;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;

    return Container(
      padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: 12),
      decoration: BoxDecoration(
        border: isFirst
            ? null
            : Border(top: BorderSide(color: t.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.textMuted, fontSize: 12),
                ),
                Text(
                  'Contrato ${entry.contract}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: t.bgElev2,
              borderRadius: BorderRadius.circular(LlRadius.pill),
            ),
            child: Text(
              'R\$ ${entry.fee.toStringAsFixed(0)}',
              style: TextStyle(
                color: t.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
