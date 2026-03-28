import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/boleto_item.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';

/// Painel exclusivo de boletos do franqueado
class BoletosScreen extends StatelessWidget {
  const BoletosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.boletos,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Meus Boletos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
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
            ...mockBoletos.map((b) => BoletoItem(
              boleto: Map<String, dynamic>.from(b as Map),
            )),
          ],
        ),
      ),
    );
  }
}
