import 'package:flutter/material.dart';
import 'roleta_widget.dart';

/// Card de faturamento — fundo roxo escuro, números animados
class MoneyCard extends StatelessWidget {
  final double total;
  final double bruto;
  final double liquido;
  final VoidCallback? onTap;

  const MoneyCard({
    super.key,
    required this.total,
    required this.bruto,
    required this.liquido,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2860),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RoletaWidget(value: total,   label: 'FATURAMENTO TOTAL DO MÊS', fontSize: 28),
            const Divider(color: Colors.white24, height: 24),
            RoletaWidget(value: bruto,   label: 'FAT BRUTO',   fontSize: 20),
            const SizedBox(height: 12),
            RoletaWidget(value: liquido, label: 'FAT LÍQUIDO', fontSize: 20),
            const SizedBox(height: 8),
            const Text(
              '* Não inclui impostos, royalties e mkt',
              style: TextStyle(fontSize: 10, color: Color(0x99AFA9EC)),
            ),
          ],
        ),
      ),
    );
  }
}
