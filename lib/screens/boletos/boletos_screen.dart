import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/boleto_item.dart';
import '../../providers/boletos_provider.dart';
import '../../models/boleto.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Meus Boletos',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)),
                  boletosAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (boletos) {
                      final filtrados = _filtrar(boletos);
                      return Text(
                        '${filtrados.length} boleto${filtrados.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Filtro por categoria (chips) ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tipoFiltros
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(t,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _filtroTipo == t
                                          ? Colors.white
                                          : AppColors.textPrimary)),
                              selected: _filtroTipo == t,
                              selectedColor: AppColors.primaryOrange,
                              checkmarkColor: Colors.white,
                              onSelected: (_) =>
                                  setState(() => _filtroTipo = t),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Filtro por status ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusFiltros
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(s,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _filtroStatus == s
                                          ? Colors.white
                                          : Colors.grey)),
                              selected: _filtroStatus == s,
                              selectedColor: _statusColor(s),
                              onSelected: (_) =>
                                  setState(() => _filtroStatus = s),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                      const SizedBox(height: 12),
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
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 40, color: Colors.black26),
                          SizedBox(height: 8),
                          Text('Nenhum boleto encontrado.',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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

  Color _statusColor(String s) {
    switch (s) {
      case 'Vencido':
        return AppColors.dangerRed;
      case 'Pago':
        return AppColors.successGreen;
      default:
        return AppColors.warningYellow;
    }
  }
}
