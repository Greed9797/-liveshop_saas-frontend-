import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/financeiro_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';
import '../../services/api_service.dart';
import '../../widgets/money_text.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/client_avatar.dart';

class FinanceiroScreen extends ConsumerStatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  ConsumerState<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends ConsumerState<FinanceiroScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(financeiroPeriodoProvider);

    return AppScreenScaffold(
      currentRoute: AppRoutes.financeiro,
      title: 'Financeiro',
      eyebrow: 'Consolidado da franquia',
      titleSerif: true,
      subtitle: 'Faturamento, custos e fluxo de caixa do período selecionado.',
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Material(
              color: AppColors.bgCard,
              elevation: 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.x5,
                      right: AppSpacing.x5,
                      top: AppSpacing.x3,
                    ),
                    child: Row(
                      children: [
                        AppSegmentedControl<String>(
                          segments: const ['mes', 'trimestre', 'ano'],
                          selected: selectedPeriod,
                          labelOf: (s) => {
                                'mes': 'Mês',
                                'trimestre': 'Trimestre',
                                'ano': '12 meses',
                              }[s] ??
                              s,
                          onChanged: (s) => ref
                              .read(financeiroPeriodoProvider.notifier)
                              .state = s,
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(
                          icon: Icon(Icons.account_balance_wallet_outlined, size: 18),
                          text: 'Operacional'),
                      Tab(
                          icon: Icon(Icons.table_chart_outlined, size: 18),
                          text: 'Por Cliente'),
                      Tab(
                          icon: Icon(Icons.donut_large_outlined, size: 18),
                          text: 'Recebíveis'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OperacionalTab(selectedPeriod: selectedPeriod),
                  _PorClienteTab(),
                  const _ReceiveisTab(),
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
  final String selectedPeriod;
  const _OperacionalTab({required this.selectedPeriod});

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

    final chips = _categorias
        .map((cat) => ActionChip(
              avatar: Icon(cat.icon, size: 14),
              label: Text(cat.label),
              onPressed: () =>
                  _showAdicionarCustoComCategoria(context, ref, cat),
            ))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Resumo rápido — KpiFinCard strip ────────────────────────────
          resumoAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (r) {
              final bruto = _formatBRL(r.fatBruto);
              final liquido = _formatBRL(r.fatLiquido);
              final custos = _formatBRL(r.totalCustos);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x5),
                child: ResponsiveGrid(
                  mobileColumns: 1,
                  tabletColumns: 3,
                  desktopColumns: 3,
                  spacing: AppSpacing.x3,
                  runSpacing: AppSpacing.x3,
                  children: [
                    KpiFinCard(label: 'Faturamento Bruto', prefix: 'R\$', value: bruto, tone: KpiFinTone.info, sub: 'no mês'),
                    KpiFinCard(label: 'Faturamento Líquido', prefix: 'R\$', value: liquido, tone: KpiFinTone.success, sub: 'após custos'),
                    KpiFinCard(label: 'Custos Operacionais', prefix: 'R\$', value: custos, tone: KpiFinTone.danger, sub: 'total do mês'),
                  ],
                ),
              );
            },
          ),

          // ── Fluxo de Caixa ─────────────────────────────────────────────
          AppSectionHeader(title: 'Fluxo de Caixa — Mês Atual'),

          fluxoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Text('Erro ao carregar fluxo de caixa',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
            data: (fluxo) => _FluxBar(
              entradas: fluxo.totalEntradas,
              saidas: fluxo.totalSaidas,
              saldo: fluxo.saldo,
            ),
          ),
          const SizedBox(height: AppSpacing.x6),

          // ── Cadastrar custo ────────────────────────────────────────────
          AppSectionHeader(
            title: 'Custos do Mês',
            trailing: AppPrimaryButton(
              icon: Icons.add,
              label: 'Adicionar',
              onPressed: () => _showAdicionarCusto(context, ref),
            ),
          ),

          // Botões de categoria rápida
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: chips,
          ),
          const SizedBox(height: AppSpacing.x4),

          // Lista de custos cadastrados
          custosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (custos) => custos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
                      child: Text('Nenhum custo cadastrado este mês.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
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
              AppTextField(
                controller: descCtrl,
                hint: 'Descrição',
              ),
              const SizedBox(height: AppSpacing.x3),
              AppTextField(
                controller: valorCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                hint: 'R\$ Valor',
              ),
              const SizedBox(height: AppSpacing.x3),
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
            AppPrimaryButton(
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
                        SnackBar(content: Text(ApiService.extractErrorMessage(e))));
                  }
                }
              },
              label: 'SALVAR',
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
          Text(ApiService.extractErrorMessage(e), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.x3),
          AppPrimaryButton(
            onPressed: () =>
                ref.read(faturamentoPorClienteProvider.notifier).refresh(),
            label: 'Tentar novamente',
          ),
        ]),
      ),
      data: (clientes) {
        final total = clientes.fold(0.0, (s, c) => s + c.total);

        if (clientes.isEmpty) {
          return Center(
            child: Text('Nenhum faturamento registrado este mês.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          );
        }

        final tableRows = clientes.map((c) {
          final pct = total > 0 ? (c.total / total * 100) : 0.0;
          return AppTableRow(
            cells: [
              Row(
                children: [
                  ClientAvatar(initials: c.nome.isNotEmpty ? c.nome[0] : '?', size: 36, tone: ClientAvatarTone.success),
                  const SizedBox(width: 8),
                  Text(c.nome, style: AppTypography.label.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              Text(c.nicho ?? '—', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              MoneyText(value: c.total, fontSize: 14, fontWeight: FontWeight.w600),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${pct.toStringAsFixed(1)}%', style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 4,
                        backgroundColor: AppColors.bgBase,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            onTap: () {
              // navigate to client detail — hook for future
            },
          );
        }).toList();

        final formattedTotal = 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: AppTable(
            columns: const [
              AppTableColumn(label: 'CLIENTE', align: 'left'),
              AppTableColumn(label: 'NICHO', align: 'left'),
              AppTableColumn(label: 'FATURAMENTO', align: 'right'),
              AppTableColumn(label: 'PARTICIPAÇÃO', align: 'right'),
            ],
            rows: tableRows,
            footer: Text('Total: $formattedTotal', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            hoverHighlight: true,
          ),
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
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow + micro-título (peach gradient através do scaffold)
            Row(
              children: [
                Container(
                  width: 18,
                  height: 1,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'RECEBÍVEIS DO FRANQUEADO',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x4),
            // 3 KPI cards com tipografia unificada (usando KpiFinCard)
            ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 3,
              desktopColumns: 3,
              spacing: AppSpacing.x3,
              runSpacing: AppSpacing.x3,
              children: [
                KpiFinCard(
                  label: 'Bruto',
                  value: _formatBRL(resumo.fatBruto),
                  tone: KpiFinTone.info,
                  sub: 'faturamento total',
                ),
                KpiFinCard(
                  label: 'Líquido',
                  value: _formatBRL(resumo.fatLiquido),
                  tone: KpiFinTone.success,
                  sub: 'após custos',
                ),
                KpiFinCard(
                  label: 'Custos',
                  value: _formatBRL(resumo.totalCustos),
                  tone: KpiFinTone.danger,
                  sub: 'operacionais',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Card Bruto × Líquido × Custos com gradiente suave ─────────
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primarySofter, AppColors.bgCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.primarySoft),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.all(AppSpacing.x5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bruto × Líquido × Custos',
                      style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    'Comparativo do período selecionado.',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  _BrutoLiquidoBar(resumo: resumo),
                  const SizedBox(height: AppSpacing.x4),
                  const Wrap(
                    spacing: AppSpacing.x4,
                    runSpacing: AppSpacing.x2,
                    children: [
                      _LegendDot(color: AppColors.info, label: 'Fat. Bruto'),
                      _LegendDot(
                          color: AppColors.success, label: 'Fat. Líquido'),
                      _LegendDot(color: AppColors.danger, label: 'Custos'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x5),

            // ── Botão Meus Boletos ────────────────────────────────────────
            AppPrimaryButton(
              icon: Icons.receipt_long_rounded,
              label: 'VER MEUS BOLETOS',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.boletos),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────────

String _formatBRL(double v) {
  if (v >= 1000) {
    return '${(v / 1000).toStringAsFixed(1)}k';
  }
  return v.toStringAsFixed(2).replaceAll('.', ',');
}

class _FluxBar extends StatelessWidget {
  final double entradas;
  final double saidas;
  final double saldo;

  const _FluxBar({required this.entradas, required this.saidas, required this.saldo});

  String _fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final total = entradas + saidas;
    final pctEntradas = total > 0 ? entradas / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.x3),
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ENTRADAS',
                        style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                            letterSpacing: 0.8)),
                    const SizedBox(height: AppSpacing.x1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(_fmt(entradas),
                          style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                decoration: BoxDecoration(
                  color: saldo >= 0
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${saldo >= 0 ? '+' : ''}${_fmt(saldo)}',
                  style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          saldo >= 0 ? AppColors.success : AppColors.danger),
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SAÍDAS',
                        style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                            letterSpacing: 0.8)),
                    const SizedBox(height: AppSpacing.x1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(_fmt(saidas),
                          style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColors.bgMuted,
            ),
            child: Row(
              children: [
                Flexible(
                  flex: (pctEntradas * 100).round().clamp(1, 99),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                      gradient: LinearGradient(colors: [AppColors.success, AppColors.success]),
                    ),
                  ),
                ),
                Flexible(
                  flex: ((1 - pctEntradas) * 100).round().clamp(1, 99),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ABA C: RECEBÍVEIS

class _BrutoLiquidoBar extends StatelessWidget {
  final FinanceiroResumo resumo;
  const _BrutoLiquidoBar({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final max = (resumo.fatBruto > 0 ? resumo.fatBruto : 1).toDouble();
    return Column(
      children: [
        _buildBar(context, 'Bruto', resumo.fatBruto.toDouble(), max, AppColors.info),
        const SizedBox(height: AppSpacing.x2),
        _buildBar(context, 'Líquido', resumo.fatLiquido.toDouble(), max,
            AppColors.success),
        const SizedBox(height: AppSpacing.x2),
        _buildBar(context,
            'Custos', resumo.totalCustos.toDouble(), max, AppColors.danger),
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
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 14,
              backgroundColor: AppColors.bgBase,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        Text(
          'R\$ ${value.toStringAsFixed(0)}',
          style: AppTypography.caption.copyWith(
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
      leading: ClientAvatar(
        initials: custo.descricao.isNotEmpty ? custo.descricao[0] : '?',
        size: 36,
        tone: ClientAvatarTone.neutral,
      ),
      title: Text(custo.descricao,
          style: AppTypography.label.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(_tipoLabel[custo.tipo] ?? custo.tipo,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(
            value: custo.valor,
            fontSize: 14,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.x1),
          IconButton(
            icon:
                const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
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
        const SizedBox(width: AppSpacing.x1),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
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

