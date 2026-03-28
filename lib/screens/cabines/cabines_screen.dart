import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cabine_card.dart';
import '../../widgets/action_button.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela expandida de gerenciamento de cabines
class CabinesScreen extends StatelessWidget {
  const CabinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.cabines,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gerenciamento de Cabines',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: 10,
                itemBuilder: (_, i) => _CabineExpandedCard(
                  cabine: Map<String, dynamic>.from(mockCabines[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card expandido de cabine com botões de ação
class _CabineExpandedCard extends StatelessWidget {
  final Map<String, dynamic> cabine;
  const _CabineExpandedCard({required this.cabine});

  bool get isLive => cabine['status'] == 'ao_vivo';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabineCard(cabine: cabine),
            const Spacer(),
            if (isLive)
              ActionButton(
                label: 'ENCERRAR',
                outlined: true,
                color: AppColors.danger,
                onPressed: () {},
              )
            else
              ActionButton(
                label: 'INICIAR LIVE',
                icon: Icons.play_arrow,
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }
}
