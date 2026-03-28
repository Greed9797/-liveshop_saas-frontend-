import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/lead_card.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';

/// Painel de leads disponíveis da franqueadora
class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  late List<Map<String, dynamic>> _leads;

  @override
  void initState() {
    super.initState();
    _leads = List<Map<String, dynamic>>.from(
      mockLeads.map((l) => Map<String, dynamic>.from(l as Map)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.leads,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leads Disponíveis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('${_leads.length} leads disponíveis para você',
              style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: _leads.isEmpty
                  ? const Center(
                      child: Text('Nenhum lead disponível no momento.',
                        style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: _leads.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => LeadCard(
                        lead: _leads[i],
                        onPegar: () => setState(() => _leads.removeAt(i)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
