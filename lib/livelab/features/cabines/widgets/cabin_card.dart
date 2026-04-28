import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../../../core/format.dart';
import '../../../widgets/ll_status_pill.dart';
import '../cabines_models.dart';

class CabinCard extends StatefulWidget {
  const CabinCard({super.key, required this.cabin, this.selected = false, this.onTap});

  final Cabin cabin;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<CabinCard> createState() => _CabinCardState();
}

class _CabinCardState extends State<CabinCard> {
  int _activeTab = 0; // 0 = agenda, 1 = história

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final c = widget.cabin;
    final isLive = c.status == CabinStatus.live;
    final isMaint = c.status == CabinStatus.maint;

    final borderColor = widget.selected
        ? t.primary
        : isLive
            ? t.primary
            : c.status == CabinStatus.busy
                ? t.infoSoft
                : t.border;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(LlRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(LlRadius.lg),
        onTap: widget.onTap,
        child: Opacity(
          opacity: isMaint ? 0.7 : 1,
          child: Container(
            padding: const EdgeInsets.all(LlSpacing.lg),
            decoration: BoxDecoration(
              color: t.bgElev1,
              borderRadius: BorderRadius.circular(LlRadius.lg),
              border: Border.all(
                color: borderColor,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: isLive
                  ? [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8))]
                  : t.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _head(t),
                const SizedBox(height: LlSpacing.md),
                _body(t),
                if (!isMaint) ...[
                  const SizedBox(height: LlSpacing.md),
                  _tabs(t),
                  const SizedBox(height: LlSpacing.sm),
                  _list(t),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _head(LlTokens t) {
    final c = widget.cabin;
    final pill = switch (c.status) {
      CabinStatus.live => const LlStatusPill(kind: LlStatusKind.live, label: 'AO VIVO', dot: true),
      CabinStatus.busy => const LlStatusPill(kind: LlStatusKind.busy, label: 'PREPARANDO'),
      CabinStatus.free => const LlStatusPill(kind: LlStatusKind.free, label: 'LIVRE'),
      CabinStatus.maint => const LlStatusPill(kind: LlStatusKind.maint, label: 'MANUTENÇÃO'),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.number.toString().padLeft(2, '0'),
          style: GoogleFonts.instrumentSerif(
            color: c.status == CabinStatus.live
                ? t.primary
                : c.status == CabinStatus.maint
                    ? t.textFaint
                    : t.textPrimary,
            fontStyle: FontStyle.italic,
            fontSize: 32,
            fontWeight: FontWeight.w400,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const Spacer(),
        pill,
      ],
    );
  }

  Widget _body(LlTokens t) {
    final c = widget.cabin;
    switch (c.status) {
      case CabinStatus.live:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.client ?? '', style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              '${c.presenter} · em transmissão há ${c.duration}',
              style: TextStyle(color: t.textMuted, fontSize: 11),
            ),
            const SizedBox(height: LlSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: t.hairline),
                  bottom: BorderSide(color: t.hairline),
                ),
              ),
              child: Row(
                children: [
                  _stat(t, label: 'Espectadores', value: LlFormat.compactInt(c.views)),
                  _stat(t, label: 'Pedidos', value: c.orders.toString()),
                  _stat(t, label: 'GMV', value: 'R\$${(c.gmv / 1000).toStringAsFixed(1)}k', color: t.primary),
                ],
              ),
            ),
          ],
        );
      case CabinStatus.busy:
        return _twoLines(t, 'Setup em andamento', c.client ?? '', mutedTitle: false);
      case CabinStatus.free:
        return _twoLines(t, 'Disponível', 'Pronta para iniciar uma live', mutedTitle: true);
      case CabinStatus.maint:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Em manutenção', style: TextStyle(color: t.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(c.maintenanceReason ?? '', style: TextStyle(color: t.textSecondary, fontSize: 12)),
            const SizedBox(height: LlSpacing.md),
            Container(
              padding: const EdgeInsets.all(LlSpacing.md),
              decoration: BoxDecoration(
                color: t.warningSoft,
                borderRadius: BorderRadius.circular(LlRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 14, color: t.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(color: t.warning, fontSize: 12),
                        children: [
                          const TextSpan(text: 'Retorno previsto às '),
                          TextSpan(
                            text: c.maintenanceEta ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _twoLines(LlTokens t, String title, String subtitle, {required bool mutedTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: mutedTitle ? t.textMuted : t.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: t.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _stat(LlTokens t, {required String label, required String value, Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? t.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(color: t.textMuted, fontSize: 9, letterSpacing: 0.6, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _tabs(LlTokens t) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.bgBase,
        borderRadius: BorderRadius.circular(LlRadius.md),
        border: Border.all(color: t.hairline),
      ),
      child: Row(
        children: [
          _tabBtn(t, idx: 0, icon: Icons.calendar_today_outlined, label: 'Agenda', badge: widget.cabin.agenda.length),
          const SizedBox(width: 4),
          _tabBtn(t, idx: 1, icon: Icons.history, label: 'Histórico'),
        ],
      ),
    );
  }

  Widget _tabBtn(LlTokens t, {required int idx, required IconData icon, required String label, int? badge}) {
    final active = _activeTab == idx;
    return Expanded(
      child: Material(
        color: active ? t.bgElev2 : Colors.transparent,
        borderRadius: BorderRadius.circular(LlRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(LlRadius.sm),
          onTap: () => setState(() => _activeTab = idx),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: active ? t.textPrimary : t.textMuted),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? t.textPrimary : t.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (badge != null && badge > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      borderRadius: BorderRadius.circular(LlRadius.sm),
                    ),
                    child: Text(
                      badge.toString(),
                      style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(LlTokens t) {
    final c = widget.cabin;
    final items = _activeTab == 0 ? c.agenda.length : c.history.length;
    if (items == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            _activeTab == 0 ? 'Sem agendamentos próximos' : 'Sem transmissões anteriores',
            style: TextStyle(color: t.textFaint, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 140),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(items, (i) {
            if (_activeTab == 0) {
              final a = c.agenda[i];
              return _row(
                t,
                last: i == items - 1,
                time: a.time,
                timeColor: t.primary,
                title: a.name,
                meta: '${a.presenter ?? "—"}${a.duration != null ? " · ${a.duration}" : ""}',
              );
            } else {
              final h = c.history[i];
              return _row(
                t,
                last: i == items - 1,
                time: h.time,
                timeColor: t.textMuted,
                title: h.name,
                meta: 'R\$ ${(h.gmv / 1000).toStringAsFixed(1)}k · ${LlFormat.integer(h.views)} esp.',
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _row(
    LlTokens t, {
    required bool last,
    required String time,
    required Color timeColor,
    required String title,
    required String meta,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: t.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              time,
              style: TextStyle(
                color: timeColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
