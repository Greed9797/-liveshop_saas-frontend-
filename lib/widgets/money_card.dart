import 'package:flutter/material.dart';

class MoneyCard extends StatefulWidget {
  final double total;
  final double bruto;
  final double futuro;

  const MoneyCard({
    super.key,
    required this.total,
    required this.bruto,
    required this.futuro,
  });

  @override
  State<MoneyCard> createState() => _MoneyCardState();
}

class _MoneyCardState extends State<MoneyCard> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFBDBDBD), // Cinza da referência
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('TOTAL:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                          _isVisible ? Icons.visibility : Icons.visibility_off,
                          size: 20),
                      onPressed: () => setState(() => _isVisible = !_isVisible),
                    ),
                  ],
                ),
                Text(
                  _isVisible
                      ? 'R\$ ${widget.total.toStringAsFixed(2).replaceAll('.', ',')}'
                      : 'R\$ *****',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SubValue(
                    label: 'FATURAMENTO BRUTO',
                    value: widget.bruto,
                    isVisible: _isVisible,
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.black12),
                Expanded(
                  child: _SubValue(
                    label: 'RECEITAS FUTURAS',
                    value: widget.futuro,
                    isVisible: _isVisible,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SubValue extends StatelessWidget {
  final String label;
  final double value;
  final bool isVisible;

  const _SubValue(
      {required this.label, required this.value, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(
              isVisible
                  ? 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}'
                  : 'R\$ *****',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
