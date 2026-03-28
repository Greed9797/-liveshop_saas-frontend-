import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Painel do cliente parceiro com banner AO VIVO pulsante
class ClienteScreen extends StatelessWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = mockClienteMetrics;
    return AppScaffold(
      currentRoute: AppRoutes.cliente,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _LiveBanner(),
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.store, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Loja XYZ Moda',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text('Parceiro desde Jan/2025',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                    width: 180,
                    child: MetricCard(
                      label: 'CRESCIMENTO',
                      value: '+${m['crescimento']}%',
                      icon: Icons.trending_up,
                      iconColor: AppColors.success,
                    )),
                SizedBox(
                    width: 180,
                    child: MetricCard(
                      label: 'VOLUME VENDIDO',
                      value: '${m['volume']} itens',
                      icon: Icons.inventory_2_outlined,
                    )),
                SizedBox(
                    width: 180,
                    child: MetricCard(
                      label: 'FATURAMENTO',
                      value:
                          'R\$ ${(m['faturamento'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
                      icon: Icons.attach_money,
                      iconColor: AppColors.primary,
                    )),
                SizedBox(
                    width: 180,
                    child: MetricCard(
                      label: 'LUCRO ESTIMADO',
                      value:
                          'R\$ ${(m['lucro'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
                      icon: Icons.savings_outlined,
                      iconColor: AppColors.success,
                    )),
                SizedBox(
                    width: 180,
                    child: MetricCard(
                      label: 'COMISSÃO',
                      value:
                          'R\$ ${(m['comissao'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
                      icon: Icons.percent,
                      iconColor: AppColors.lilac,
                    )),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Mais Vendidos',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            const SizedBox(height: 10),
            ...(m['maisVendidos'] as List<String>).asMap().entries.map((e) =>
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text('${e.key + 1}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white)),
                  ),
                  title: Text(e.value),
                )),
          ],
        ),
      ),
    );
  }
}

/// Banner pulsante "VOCÊ ESTÁ AO VIVO AGORA"
class _LiveBanner extends StatefulWidget {
  const _LiveBanner();
  @override
  State<_LiveBanner> createState() => _LiveBannerState();
}

class _LiveBannerState extends State<_LiveBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.live_tv, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('VOCÊ ESTÁ AO VIVO AGORA',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
