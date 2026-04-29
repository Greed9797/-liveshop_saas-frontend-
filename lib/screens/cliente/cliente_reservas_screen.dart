import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../design_system/app_colors.dart' as ds_colors;
import '../../design_system/app_tokens.dart' as ds_tokens;
import '../../design_system/app_typography.dart' as ds_typography;
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class ClienteReserva {
  final String id;
  final String cabineId;
  final int cabineNumero;
  final String data;
  final String horaInicio;
  final String horaFim;
  final String status;
  final String? observacoes;

  const ClienteReserva({
    required this.id,
    required this.cabineId,
    required this.cabineNumero,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    this.observacoes,
  });

  factory ClienteReserva.fromJson(Map<String, dynamic> j) => ClienteReserva(
        id: j['id'] as String,
        cabineId: j['cabine_id'] as String,
        cabineNumero: (j['cabine_numero'] as num).toInt(),
        data: j['data'] as String,
        horaInicio: j['hora_inicio'] as String,
        horaFim: j['hora_fim'] as String,
        status: j['status'] as String,
        observacoes: j['observacoes'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final clienteReservasProvider =
    AsyncNotifierProvider<_ClienteReservasNotifier, List<ClienteReserva>>(
        _ClienteReservasNotifier.new);

class _ClienteReservasNotifier
    extends AsyncNotifier<List<ClienteReserva>> {
  @override
  Future<List<ClienteReserva>> build() => _fetch();

  Future<List<ClienteReserva>> _fetch() async {
    final data = await ApiService.get('/cliente/reservas');
    final list = data as List<dynamic>;
    return list.map((e) => ClienteReserva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ClienteReservasScreen extends ConsumerWidget {
  const ClienteReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservasAsync = ref.watch(clienteReservasProvider);

    return AppScaffold(
      currentRoute: AppRoutes.clienteReservas,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onRefresh: () => ref.read(clienteReservasProvider.notifier).refresh(),
                onSolicitar: () => Navigator.pushNamed(context, AppRoutes.clienteAgenda),
              ),
              Expanded(
                child: reservasAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ApiService.extractErrorMessage(e),
                          style: ds_typography.AppTypography.bodyMedium.copyWith(
                            color: ds_colors.AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ds_tokens.AppSpacing.x4),
                        TextButton.icon(
                          onPressed: () => ref.read(clienteReservasProvider.notifier).refresh(),
                          icon: Icon(PhosphorIcons.arrowClockwise(), size: 16),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                  data: (reservas) => reservas.isEmpty
                      ? _EmptyState(
                          onSolicitar: () =>
                              Navigator.pushNamed(context, AppRoutes.clienteAgenda),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(ds_tokens.AppSpacing.x6),
                          itemCount: reservas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: ds_tokens.AppSpacing.x3),
                          itemBuilder: (_, i) => _ReservaCard(reserva: reservas[i]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onSolicitar;

  const _Header({required this.onRefresh, required this.onSolicitar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ds_tokens.AppSpacing.x6,
        ds_tokens.AppSpacing.x6,
        ds_tokens.AppSpacing.x6,
        ds_tokens.AppSpacing.x4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minha Agenda',
                  style: ds_typography.AppTypography.h2.copyWith(
                    color: ds_colors.AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lives solicitadas e confirmadas',
                  style: ds_typography.AppTypography.bodySmall.copyWith(
                    color: ds_colors.AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(PhosphorIcons.arrowClockwise(), size: 20),
            color: ds_colors.AppColors.textSecondary,
          ),
          const SizedBox(width: ds_tokens.AppSpacing.x2),
          FilledButton.icon(
            onPressed: onSolicitar,
            icon: Icon(PhosphorIcons.plusCircle(), size: 16),
            label: const Text('Solicitar live'),
            style: FilledButton.styleFrom(
              backgroundColor: ds_colors.AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: ds_tokens.AppSpacing.x4,
                vertical: ds_tokens.AppSpacing.x2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final VoidCallback onSolicitar;

  const _EmptyState({required this.onSolicitar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.calendarBlank(),
            size: 48,
            color: ds_colors.AppColors.textMuted,
          ),
          const SizedBox(height: ds_tokens.AppSpacing.x4),
          Text(
            'Nenhuma live agendada',
            style: ds_typography.AppTypography.h3.copyWith(
              color: ds_colors.AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: ds_tokens.AppSpacing.x2),
          Text(
            'Solicite uma live para começar',
            style: ds_typography.AppTypography.bodySmall.copyWith(
              color: ds_colors.AppColors.textMuted,
            ),
          ),
          const SizedBox(height: ds_tokens.AppSpacing.x6),
          FilledButton.icon(
            onPressed: onSolicitar,
            icon: Icon(PhosphorIcons.plusCircle(), size: 16),
            label: const Text('Solicitar live'),
            style: FilledButton.styleFrom(
              backgroundColor: ds_colors.AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reserva card
// ---------------------------------------------------------------------------

class _ReservaCard extends StatelessWidget {
  final ClienteReserva reserva;

  const _ReservaCard({required this.reserva});

  static final DateFormat _dateFmt =
      DateFormat("EEE, dd/MM/yyyy", 'pt_BR');

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(reserva.status);
    final statusLabel = _statusLabel(reserva.status);

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(reserva.data);
    } catch (_) {}

    final dateStr = parsedDate != null ? _dateFmt.format(parsedDate) : reserva.data;

    return Container(
      decoration: BoxDecoration(
        color: ds_colors.AppColors.bgCard,
        borderRadius: BorderRadius.circular(ds_tokens.AppRadius.md),
        border: Border.all(color: ds_colors.AppColors.border),
      ),
      padding: const EdgeInsets.all(ds_tokens.AppSpacing.x4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: ds_tokens.AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Cabine ${reserva.cabineNumero.toString().padLeft(2, '0')}',
                      style: ds_typography.AppTypography.label.copyWith(
                        color: ds_colors.AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _StatusPill(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(PhosphorIcons.calendarBlank(),
                        size: 13, color: ds_colors.AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: ds_typography.AppTypography.bodySmall.copyWith(
                        color: ds_colors.AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: ds_tokens.AppSpacing.x3),
                    Icon(PhosphorIcons.clock(),
                        size: 13, color: ds_colors.AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${reserva.horaInicio} – ${reserva.horaFim}',
                      style: ds_typography.AppTypography.bodySmall.copyWith(
                        color: ds_colors.AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (reserva.observacoes != null && reserva.observacoes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reserva.observacoes!,
                    style: ds_typography.AppTypography.caption.copyWith(
                      color: ds_colors.AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'confirmada' => ds_colors.AppColors.success,
      'pendente' => ds_colors.AppColors.warning,
      'em_andamento' => ds_colors.AppColors.primary,
      _ => ds_colors.AppColors.textMuted,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'confirmada' => 'Confirmada',
      'pendente' => 'Pendente',
      'em_andamento' => 'Em andamento',
      'encerrada' => 'Encerrada',
      _ => status,
    };
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ds_tokens.AppRadius.full),
      ),
      child: Text(
        label,
        style: ds_typography.AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
