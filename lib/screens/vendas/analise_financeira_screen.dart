import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela de análise financeira — simula loading e exibe resultado
class AnaliseFinanceiraScreen extends StatefulWidget {
  const AnaliseFinanceiraScreen({super.key});
  @override
  State<AnaliseFinanceiraScreen> createState() => _AnaliseState();
}

class _AnaliseState extends State<AnaliseFinanceiraScreen> {
  // 0=analisando, 1=aprovado, 2=recusado
  int _fase = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _fase = 1); // mockado: sempre aprovado
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.vendas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: switch (_fase) {
                0 => const _AnalisandoView(),
                1 => _AprovadoView(
                    onContinuar: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.vendas, (_) => false),
                  ),
                _ => _RecusadoView(
                    onAssumir:  () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.vendas, (_) => false),
                    onCancelar: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.vendas, (_) => false),
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalisandoView extends StatelessWidget {
  const _AnalisandoView();
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(),
      SizedBox(height: 24),
      Text('Analisando dados financeiros...',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      SizedBox(height: 8),
      Text('Consultando score de crédito',
        style: TextStyle(color: Colors.grey)),
    ],
  );
}

class _AprovadoView extends StatelessWidget {
  final VoidCallback onContinuar;
  const _AprovadoView({required this.onContinuar});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
      const SizedBox(height: 16),
      const Text('APROVADO',
        style: TextStyle(fontSize: 24, color: AppColors.success, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      const Text('Cliente aprovado para contrato ativo!'),
      const SizedBox(height: 24),
      ActionButton(label: 'CONTINUAR', onPressed: onContinuar, color: AppColors.success),
    ],
  );
}

class _RecusadoView extends StatelessWidget {
  final VoidCallback onAssumir;
  final VoidCallback onCancelar;
  const _RecusadoView({required this.onAssumir, required this.onCancelar});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.warning_rounded, color: AppColors.danger, size: 64),
      const SizedBox(height: 16),
      const Text('CLIENTE COM ALTO RISCO',
        style: TextStyle(fontSize: 18, color: AppColors.danger, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Você pode negociar pagamento antecipado ou assumir o risco.',
          style: TextStyle(color: AppColors.danger),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionButton(label: 'ASSUMIR RISCO',       onPressed: onAssumir,  color: AppColors.warning),
          const SizedBox(width: 12),
          ActionButton(label: 'CANCELAR CONTRATO',   onPressed: onCancelar, outlined: true, color: AppColors.danger),
        ],
      ),
    ],
  );
}
