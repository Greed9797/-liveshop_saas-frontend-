import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';

/// Lista de manuais e documentos da franqueadora
class ManuaisScreen extends StatelessWidget {
  const ManuaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.manuais,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manuais e Documentos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: mockManuais.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final m = mockManuais[i] as Map;
                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                    title: Text(m['titulo'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Atualizado em: ${m['data']}'),
                    trailing: ActionButton(
                      label: 'VER',
                      icon: Icons.open_in_new,
                      outlined: true,
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
