import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'action_button.dart';

/// Card de lead com botão "PEGAR LEAD"
class LeadCard extends StatelessWidget {
  final Map<String, dynamic> lead;
  final VoidCallback? onPegar;
  const LeadCard({super.key, required this.lead, this.onPegar});

  @override
  Widget build(BuildContext context) {
    final isNovo = lead['novo'] == true;
    final fat = lead['fat'] as int;
    final fatFormatted = fat.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(lead['nome'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (isNovo) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('NOVO',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${lead['nicho']} • ${lead['cidade']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Fat. est.: R\$ $fatFormatted',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            ActionButton(
              label: 'PEGAR LEAD',
              onPressed: onPegar,
              icon: Icons.bolt_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
