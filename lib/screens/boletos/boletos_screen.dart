import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/boleto_item.dart';
import '../../providers/boletos_provider.dart';
import '../../models/boleto.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

class BoletosScreen extends ConsumerStatefulWidget {
  const BoletosScreen({super.key});

  @override
  ConsumerState<BoletosScreen> createState() => _BoletosScreenState();
}

class _BoletosScreenState extends ConsumerState<BoletosScreen> {
  String _filtroTipo = 'Todos';
  String _filtroStatus = 'Todos';

  static const _tipoFiltros = [
    'Todos',
    'Impostos',
    'Royalties',
    'Marketing',
    'Outros',
  ];

  static const _statusFiltros = ['Todos', 'Pendente', 'Vencido', 'Pago'];

  static const _tipoMap = {
    'Impostos': 'imposto',
    'Royalties': 'royalties',
    'Marketing': 'marketing',
    'Outros': 'outros',
  };

  static const _statusMap = {
    'Pendente': 'pendente',
    'Vencido': 'vencido',
    'Pago': 'pago',
  };

  List<Boleto> _filtrar(List<Boleto> boletos) {
    return boletos.where((b) {
      final tipoOk = _filtroTipo == 'Todos' ||
          b.tipo == _tipoMap[_filtroTipo];
      final statusOk = _filtroStatus == 'Todos' ||
          b.status == _statusMap[_filtroStatus];
      return tipoOk && statusOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final boletosAsync = ref.watch(boletosProvider);

    return AppScaffold(
      currentRoute: AppRoutes.boletos,
      child: RefreshIndicator(
        onRefresh: () => ref.read(boletosProvider.notifier).refresh(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.xl, AppSpacing.screenPadding, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Meus Boletos',
                      style: AppTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
                  boletosAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (boletos) {
                      final filtrados = _filtrar(boletos);
                      return Text(
                        '${filtrados.length} boleto${filtrados.length == 1 ? '' : 's'}',
                        style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Filtro por categoria (chips) ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tipoFiltros
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.inlineGap),
                            child: FilterChip(
                              label: Text(t,
                                  style: AppTypography.caption.copyWith(
                                      color: _filtroTipo == t
                                          ? Colors.white
                                          : context.colors.textPrimary)),
                              selected: _filtroTipo == t,
                              selectedColor: context.colors.primary,
                              checkmarkColor: Colors.white,
                              onSelected: (_) =>
                                  setState(() => _filtroTipo = t),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Filtro por status ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusFiltros
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.inlineGap),
                            child: ChoiceChip(
                              label: Text(s,
                                  style: AppTypography.caption.copyWith(
                                      fontSize: 11,
                                      color: _filtroStatus == s
                                          ? Colors.white
                                          : context.colors.textSecondary)),
                              selected: _filtroStatus == s,
                              selectedColor: _statusColor(s, context),
                              onSelected: (_) =>
                                  setState(() => _filtroStatus = s),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Lista ────────────────────────────────────────────────────
            Expanded(
              child: boletosAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Erro: $e'),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(boletosProvider.notifier).refresh(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
                data: (boletos) {
                  final filtrados = _filtrar(boletos);
                  if (filtrados.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 40, color: Colors.black26),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Nenhum boleto encontrado.',
                              style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
                    itemCount: filtrados.length,
                    itemBuilder: (_, i) => BoletoItem(boleto: filtrados[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s, BuildContext context) {
    switch (s) {
      case 'Vencido':
        return context.colors.error;
      case 'Pago':
        return context.colors.success;
      default:
        return context.colors.warning;
    }
  }
}
