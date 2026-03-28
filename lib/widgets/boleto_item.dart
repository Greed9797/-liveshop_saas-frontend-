import 'package:flutter/material.dart';
import 'status_badge.dart';
import 'action_button.dart';

/// Linha de boleto com status e vencimento
class BoletoItem extends StatelessWidget {
  final Map<String, dynamic> boleto;
  const BoletoItem({super.key, required this.boleto});

  @override
  Widget build(BuildContext context) {
    final valor = (boleto['valor'] as double)
        .toStringAsFixed(2)
        .replaceAll('.', ',')
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(boleto['tipo'] as String,
            style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text('R\$ $valor',
            style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(boleto['vencimento'] as String,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
          Expanded(flex: 2, child: StatusBadge(status: boleto['status'] as String)),
          ActionButton(label: 'VER BOLETO', outlined: true, onPressed: () {}),
        ],
      ),
    );
  }
}
