import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_scaffold.dart';
import '../../providers/financeiro_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';
import '../../widgets/money_text.dart';
import '../../widgets/responsive_grid.dart';

class FinanceiroScreen extends ConsumerWidget {
  const FinanceiroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      currentRoute: AppRoutes.financeiro,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: context.colors.cardBackground,
              child: TabBar(
                labelColor: context.colors.primary,
                unselectedLabelColor: context.colors.textSecondary,
                indicatorColor: context.colors.primary,
                tabs: const [
                  Tab(
                      icon:
                          Icon(Icons.account_balance_wallet_outlined, size: 18),
                      text: 'Operacional'),
                  Tab(
                      icon: Icon(Icons.table_chart_outlined, size: 18),
                      text: 'Por Cliente'),
                  Tab(
                      icon: Icon(Icons.donut_large_outlined, size: 18),
                      text: 'Recebíveis'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _OperacionalTab(),
                  _PorClienteTab(),
                  _ReceiveisTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ABA A: OPERACIONAL (Custos + Fluxo de Caixa) ────────────────────────────

class _OperacionalTab extends ConsumerWidget {
  const _OperacionalTab();

  static const _categorias = [
    _Categoria('Aluguel', Icons.home_outlined, 'aluguel'),
    _Categoria('Salários', Icons.people_outline, 'salario'),
    _Categoria('Energia', Icons.bolt_outlined, 'energia'),
    _Categoria('Internet', Icons.wifi, 'internet'),
    _Categoria('Outros', Icons.more_horiz, 'outros'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumoAsync = ref.watch(financeiroProvider);
    final custosAsync = ref.watch(custosProvider);
    final fluxoAsync = ref.watch(fluxoCaixaProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Resumo rápido ──────────────────────────────────────────────
          resumoAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (r) => ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 3,
              desktopColumns: 3,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _QuickMetric('BRUTO', r.fatBruto, context.colors.info),
                _QuickMetric('LÍQUIDO', r.fatLiquido, context.colors.success),
                _QuickMetric('CUSTOS', r.totalCustos, context.colors.error),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),

          // ── Fluxo de Caixa ─────────────────────────────────────────────
          Text('Fluxo de Caixa — Mês Atual',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          fluxoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Text('Erro ao carregar fluxo de caixa',
                style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
            data: (fluxo) => _FluxoCaixaBar(fluxo: fluxo),
          ),
          const SizedBox(height: 28),

          // ── Cadastrar custo ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Custos do Mês',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                onPressed: () => _showAdicionarCusto(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Botões de categoria rápida
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _categorias
                .map((cat) => ActionChip(
                      avatar: Icon(cat.icon,
                          size: 16, color: context.colors.primary),
                      label:
                          Text(cat.label, style: AppTypography.caption),
                      onPressed: () =>
                          _showAdicionarCustoComCategoria(context, ref, cat),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Lista de custos cadastrados
          custosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (custos) => custos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2l),
                      child: Text('Nenhum custo cadastrado este mês.',
                          style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
                    ),
                  )
                : Column(
                    children: custos
                        .map((c) => _CustoTile(custo: c, ref: ref))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAdicionarCusto(BuildContext context, WidgetRef ref) =>
      _showAdicionarCustoComCategoria(context, ref, null);

  void _showAdicionarCustoComCategoria(
      BuildContext context, WidgetRef ref, _Categoria? categoria) {
    final descCtrl = TextEditingController(text: categoria?.label);
    final valorCtrl = TextEditingController();
    String tipo = categoria?.valor ?? 'outros';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: const Text('Adicionar Custo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: valorCtrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: tipo,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 'aluguel', child: Text('Aluguel')),
                  DropdownMenuItem(value: 'salario', child: Text('Salários')),
                  DropdownMenuItem(value: 'energia', child: Text('Energia')),
                  DropdownMenuItem(value: 'internet', child: Text('Internet')),
                  DropdownMenuItem(value: 'outros', child: Text('Outros')),
                ],
                onChanged: (v) => setState(() => tipo = v ?? 'outros'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary),
              onPressed: () async {
                final valorStr = valorCtrl.text.replaceAll(',', '.');
                if (descCtrl.text.isEmpty || valorStr.isEmpty) return;
                final valor = double.tryParse(valorStr);
                if (valor == null || valor <= 0) return;
                Navigator.pop(ctx);
                try {
                  await ref.read(custosProvider.notifier).adicionar({
                    'descricao': descCtrl.text,
                    'valor': valor,
                    'tipo': tipo,
                    'competencia':
                        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
                  });
                  ref.invalidate(financeiroProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar: $e')));
                  }
                }
              },
              child:
                  Text('SALVAR', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ABA B: FATURAMENTO POR CLIENTE ──────────────────────────────────────────

class _PorClienteTab extends ConsumerWidget {
  const _PorClienteTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(faturamentoPorClienteProvider);

    return clientesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Erro: $e'),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () =>
                ref.read(faturamentoPorClienteProvider.notifier).refresh(),
            child: const Text('Tentar novamente'),
          ),
        ]),
      ),
      data: (clientes) {
        final total = clientes.fold(0.0, (s, c) => s + c.total);

        return Column(
          children: [
            // Header da tabela
            Container(
              color: context.colors.background,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Text('CLIENTE',
                          style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary))),
                  Expanded(
                      flex: 3,
                      child: Text('NICHO',
                          style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary))),
                  Expanded(
                      flex: 3,
                      child: Text('FATURAMENTO',
                          textAlign: TextAlign.right,
                          style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary))),
                  Expanded(
                      flex: 3,
                      child: Text('PARTICIPAÇÃO',
                          textAlign: TextAlign.right,
                          style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary))),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: clientes.isEmpty
                  ? Center(
                      child: Text('Nenhum faturamento registrado este mês.',
                          style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: clientes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = clientes[i];
                        final pct = total > 0 ? (c.total / total * 100) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(c.nome,
                                    style: AppTypography.labelLarge.copyWith(
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  c.nicho ?? '—',
                                  style: AppTypography.caption.copyWith(
                                      color: context.colors.textSecondary),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'R\$ ${c.total.toStringAsFixed(2).replaceAll('.', ',')}',
                                  textAlign: TextAlign.right,
                                  style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${pct.toStringAsFixed(1)}%',
                                      textAlign: TextAlign.right,
                                      style: AppTypography.labelSmall.copyWith(
                                          color: context.colors.primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                                    const SizedBox(height: 3),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.xs),
                                      child: LinearProgressIndicator(
                                        value: pct / 100,
                                        minHeight: 4,
                                        backgroundColor: context.colors.background,
                                        valueColor:
                                            AlwaysStoppedAnimation(
                                                context.colors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Total
            if (clientes.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  border:
                      Border(top: BorderSide(color: context.colors.divider)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('TOTAL DO MÊS: ',
                        style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary)),
                    Text(
                      'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── ABA C: RECEBÍVEIS (Roleta + BRUTO vs LÍQUIDO + Botão Boletos) ───────────

class _ReceiveisTab extends ConsumerWidget {
  const _ReceiveisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeiroAsync = ref.watch(financeiroProvider);

    return financeiroAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erro ao carregar')),
      data: (resumo) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // ── Recebíveis KPI cards ─────────────────────────────────────
            Text(
              'RECEBÍVEIS DO FRANQUEADO',
              style: AppTypography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // 3 KPI cards
            ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 3,
              desktopColumns: 3,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _KpiReceita(label: 'BRUTO', value: resumo.fatBruto, accentColor: context.colors.info),
                _KpiReceita(label: 'LÍQUIDO', value: resumo.fatLiquido, accentColor: context.colors.success),
                _KpiReceita(label: 'CUSTOS', value: resumo.totalCustos, accentColor: context.colors.error),
              ],
            ),
            const SizedBox(height: AppSpacing.x2l),

            // ── Comparação BRUTO vs LÍQUIDO ──────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BRUTO vs LÍQUIDO',
                        style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    const SizedBox(height: AppSpacing.lg),
                    _BrutoLiquidoBar(resumo: resumo),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _LegendDot(
                            color: context.colors.info, label: 'Fat. Bruto'),
                        _LegendDot(
                            color: context.colors.success,
                            label: 'Fat. Líquido'),
                        _LegendDot(color: context.colors.error, label: 'Custos'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Botão Meus Boletos ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.receipt_long_rounded,
                    color: context.colors.primary),
                label: Text('VER MEUS BOLETOS',
                    style: AppTypography.bodySmall.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.boletos),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────────

class _QuickMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color accentColor;

  const _QuickMetric(this.label, this.value, this.accentColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          MoneyText(value: value, fontSize: 22),
        ],
      ),
    );
  }
}

class _FluxoCaixaBar extends StatelessWidget {
  final FluxoCaixa fluxo;
  const _FluxoCaixaBar({required this.fluxo});

  String _fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final total = fluxo.totalEntradas + fluxo.totalSaidas;
    final pctEntradas = total > 0 ? fluxo.totalEntradas / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ENTRADAS',
                        style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: context.colors.success,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(_fmt(fluxo.totalEntradas),
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.success)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fluxo.saldo >= 0
                      ? context.colors.success.withValues(alpha: 0.1)
                      : context.colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${fluxo.saldo >= 0 ? '+' : ''}${_fmt(fluxo.saldo)}',
                  style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: fluxo.saldo >= 0
                          ? context.colors.success
                          : context.colors.error),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('SAÍDAS',
                        style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: context.colors.error,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(_fmt(fluxo.totalSaidas),
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Row(
              children: [
                Expanded(
                  flex: (pctEntradas * 100).round().clamp(1, 99),
                  child: Container(height: 12, color: context.colors.success),
                ),
                Expanded(
                  flex: ((1 - pctEntradas) * 100).round().clamp(1, 99),
                  child: Container(height: 12, color: context.colors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrutoLiquidoBar extends StatelessWidget {
  final FinanceiroResumo resumo;
  const _BrutoLiquidoBar({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final max = (resumo.fatBruto > 0 ? resumo.fatBruto : 1).toDouble();
    return Column(
      children: [
        _buildBar(context, 'Bruto', resumo.fatBruto.toDouble(), max, context.colors.info),
        const SizedBox(height: AppSpacing.sm),
        _buildBar(context, 'Líquido', resumo.fatLiquido.toDouble(), max,
            context.colors.success),
        const SizedBox(height: AppSpacing.sm),
        _buildBar(context,
            'Custos', resumo.totalCustos.toDouble(), max, context.colors.error),
      ],
    );
  }

  Widget _buildBar(BuildContext context, String label, double value, double max, Color color) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text(label,
                style: AppTypography.labelSmall.copyWith(color: context.colors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 14,
              backgroundColor: context.colors.background,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'R\$ ${value.toStringAsFixed(0)}',
          style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _CustoTile extends StatelessWidget {
  final CustoCadastrado custo;
  final WidgetRef ref;
  const _CustoTile({required this.custo, required this.ref});

  static const _tipoLabel = {
    'aluguel': 'Aluguel',
    'salario': 'Salários',
    'energia': 'Energia',
    'internet': 'Internet',
    'outros': 'Outros',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.colors.primaryLightBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.receipt_outlined,
            color: context.colors.primary, size: 18),
      ),
      title: Text(custo.descricao,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(_tipoLabel[custo.tipo] ?? custo.tipo,
          style: AppTypography.labelSmall.copyWith(color: context.colors.textSecondary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'R\$ ${custo.valor.toStringAsFixed(2).replaceAll('.', ',')}',
            style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.error),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon:
                Icon(Icons.delete_outline, size: 18, color: context.colors.textTertiary),
            onPressed: () async {
              await ref.read(custosProvider.notifier).deletar(custo.id);
              ref.invalidate(financeiroProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.labelSmall.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}

// ─── HELPER ───────────────────────────────────────────────────────────────────

class _Categoria {
  final String label;
  final IconData icon;
  final String valor;
  const _Categoria(this.label, this.icon, this.valor);
}

class _KpiReceita extends StatelessWidget {
  final String label;
  final double value;
  final Color accentColor;

  const _KpiReceita({required this.label, required this.value, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          MoneyText(value: value, fontSize: 22),
        ],
      ),
    );
  }
}
