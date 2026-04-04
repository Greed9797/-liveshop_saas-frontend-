import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/boleto.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BoletoItem extends StatelessWidget {
  final Boleto boleto;

  const BoletoItem({super.key, required this.boleto});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tipo icon + label + AUTO badge + status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _TipoIcon(tipo: boleto.tipo),
                    const SizedBox(width: 8),
                    Text(
                      _tipoLabel(boleto.tipo),
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (boleto.geradoAutomaticamente) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.infoPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AUTO',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.infoPurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                _StatusChip(status: boleto.status),
              ],
            ),

            const SizedBox(height: 12),

            // Valor + Vencimento
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valor', style: AppTypography.caption),
                      Text(
                        _formatCurrency(boleto.valor),
                        style: AppTypography.h3.copyWith(color: AppColors.primaryOrange),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(boleto.isPago ? 'Pago em' : 'Vencimento', style: AppTypography.caption),
                      Text(
                        boleto.isPago && boleto.pagoEm != null
                            ? _formatDate(boleto.pagoEm!)
                            : _formatDate(boleto.vencimento),
                        style: AppTypography.bodySmall.copyWith(
                          color: boleto.isVencido ? AppColors.dangerRed : AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Erro Asaas
            if (boleto.temErroAsaas) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Falha ao gerar no Asaas: ${boleto.asaasError}',
                  style: AppTypography.caption.copyWith(color: AppColors.dangerRed),
                ),
              ),
            ],

            // Botões de ação (só para pendente/vencido)
            if (boleto.isPendente || boleto.isVencido) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (boleto.temLinkPagamento) ...[
                    Expanded(
                      child: _LinkButton(
                        label: 'Abrir Boleto',
                        icon: Icons.open_in_new_rounded,
                        color: AppColors.primaryOrange,
                        onTap: () => _abrirLink(context, boleto.asaasUrl!),
                      ),
                    ),
                    if (boleto.asaasPix != null) ...[
                      const SizedBox(width: 8),
                      _LinkButton(
                        label: 'Copiar PIX',
                        icon: Icons.copy_rounded,
                        color: AppColors.successGreen,
                        onTap: () => _copiarPix(context, boleto.asaasPix!),
                      ),
                    ],
                  ] else ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Sem link de pagamento', style: AppTypography.caption),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _abrirLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link')),
      );
    }
  }

  void _copiarPix(BuildContext context, String pix) {
    Clipboard.setData(ClipboardData(text: pix));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIX copiado!',
              style: AppTypography.bodySmall.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _tipoLabel(String tipo) => const {
    'royalties': 'Royalties',
    'imposto': 'Imposto',
    'marketing': 'Marketing',
    'outros': 'Outros',
  }[tipo] ?? tipo;

  String _formatCurrency(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pago'    => ('Pago',     AppColors.successGreen),
      'vencido' => ('Vencido',  AppColors.dangerRed),
      _         => ('Pendente', AppColors.warningYellow),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTypography.caption.copyWith(
              color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _TipoIcon extends StatelessWidget {
  final String tipo;
  const _TipoIcon({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (tipo) {
      'royalties' => (Icons.percent_rounded,          AppColors.primaryOrange),
      'imposto'   => (Icons.account_balance_rounded,  AppColors.infoBlue),
      'marketing' => (Icons.campaign_rounded,          AppColors.infoPurple),
      _           => (Icons.receipt_long_rounded,      AppColors.textSecondary),
    };
    return Icon(icon, size: 20, color: color);
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _LinkButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.caption.copyWith(
                    color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
