import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_scaffold.dart';
import '../../providers/boletos_provider.dart';
import '../../models/boleto.dart';
import '../../routes/app_routes.dart';

/// Painel exclusivo de boletos do franqueado
class BoletosScreen extends ConsumerWidget {
  const BoletosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boletosAsync = ref.watch(boletosProvider);

    return AppScaffold(
      currentRoute: AppRoutes.boletos,
      child: RefreshIndicator(
        onRefresh: () => ref.read(boletosProvider.notifier).refresh(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Meus Boletos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  boletosAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (boletos) => Text(
                      '${boletos.length} boleto${boletos.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(flex: 3, child: Text('TIPO',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Text('VALOR',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Text('VENCIMENTO',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Text('STATUS',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: SizedBox()),
                ],
              ),
              const Divider(),
              Expanded(
                child: boletosAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Erro: $e'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(boletosProvider.notifier).refresh(),
                        child: const Text('Tentar novamente'),
                      ),
                    ]),
                  ),
                  data: (boletos) => boletos.isEmpty
                      ? const Center(
                          child: Text('Nenhum boleto encontrado.',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: boletos.length,
                          itemBuilder: (_, i) => _BoletoRow(boleto: boletos[i]),
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

class _BoletoRow extends ConsumerWidget {
  final Boleto boleto;
  const _BoletoRow({required this.boleto});

  Color get _statusColor {
    switch (boleto.status) {
      case 'vencido':
        return Colors.red;
      case 'pago':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (boleto.status) {
      case 'vencido':
        return 'VENCIDO';
      case 'pago':
        return 'PAGO';
      default:
        return 'PENDENTE';
    }
  }

  String get _tipoLabel {
    switch (boleto.tipo) {
      case 'mensalidade':
        return 'Mensalidade';
      case 'taxa_franquia':
        return 'Taxa Franquia';
      case 'equipamento':
        return 'Equipamento';
      default:
        return boleto.tipo;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venc = boleto.vencimento;
    final vencStr = '${venc.day.toString().padLeft(2, '0')}/${venc.month.toString().padLeft(2, '0')}/${venc.year}';
    final valorStr = 'R\$ ${boleto.valor.toStringAsFixed(2).replaceAll('.', ',')}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text(_tipoLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: boleto.status == 'vencido' ? Colors.red : null,
                ))),
            Expanded(flex: 2, child: Text(valorStr,
                style: TextStyle(
                  color: boleto.status == 'vencido' ? Colors.red : null,
                ))),
            Expanded(flex: 2, child: Text(vencStr,
                style: TextStyle(
                  color: boleto.status == 'vencido' ? Colors.red : null,
                ))),
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(_statusLabel,
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            )),
            Expanded(flex: 2, child: boleto.referenciaExterna != null
                ? TextButton(
                    onPressed: () async {
                      final uri = Uri.tryParse(boleto.referenciaExterna!);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('VER', style: TextStyle(fontSize: 12)),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}
