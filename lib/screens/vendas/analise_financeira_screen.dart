import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../providers/contratos_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Tela de análise financeira — chama API real e exibe resultado
class AnaliseFinanceiraScreen extends ConsumerStatefulWidget {
  const AnaliseFinanceiraScreen({super.key});
  @override
  ConsumerState<AnaliseFinanceiraScreen> createState() => _AnaliseState();
}

class _AnaliseState extends ConsumerState<AnaliseFinanceiraScreen> {
  // 0=analisando, 1=aprovado, 2=recusado, 3=erro
  int _fase = 0;
  int? _score;
  String? _erro;

  String? get _contratoId {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    return args?['contratoId'] as String?;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _analisar());
  }

  Future<void> _analisar() async {
    final contratoId = _contratoId;
    if (contratoId == null) {
      setState(() { _fase = 3; _erro = 'ID do contrato não informado'; });
      return;
    }
    try {
      final result = await ref.read(contratosProvider.notifier).analisar(contratoId);
      if (!mounted) return;
      setState(() {
        _score = result['score'] as int?;
        _fase = (result['aprovado'] as bool? ?? false) ? 1 : 2;
      });
    } catch (e) {
      if (mounted) setState(() { _fase = 3; _erro = e.toString(); });
    }
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
                    score: _score,
                    onContinuar: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.vendas, (_) => false),
                  ),
                2 => _RecusadoView(
                    score: _score,
                    onAssumir: () async {
                      final id = _contratoId;
                      if (id == null) return;
                      try {
                        await ref.read(contratosProvider.notifier).assumirRisco(id);
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.vendas, (_) => false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: $e')),
                          );
                        }
                      }
                    },
                    onCancelar: () async {
                      final id = _contratoId;
                      if (id == null) return;
                      try {
                        await ref.read(contratosProvider.notifier).cancelar(id);
                      } catch (_) {}
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.vendas, (_) => false);
                      }
                    },
                  ),
                _ => _ErroView(
                    mensagem: _erro ?? 'Erro desconhecido',
                    onTentar: () { setState(() => _fase = 0); _analisar(); },
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
      Text('Consultando score de crédito', style: TextStyle(color: Colors.grey)),
    ],
  );
}

class _AprovadoView extends StatelessWidget {
  final int? score;
  final VoidCallback onContinuar;
  const _AprovadoView({required this.score, required this.onContinuar});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
      const SizedBox(height: 16),
      const Text('APROVADO',
          style: TextStyle(fontSize: 24, color: AppColors.success, fontWeight: FontWeight.w500)),
      if (score != null) ...[
        const SizedBox(height: 8),
        Text('Score: $score/100', style: const TextStyle(color: Colors.grey)),
      ],
      const SizedBox(height: 8),
      const Text('Cliente aprovado para contrato ativo!'),
      const SizedBox(height: 24),
      ActionButton(label: 'CONTINUAR', onPressed: onContinuar, color: AppColors.success),
    ],
  );
}

class _RecusadoView extends StatelessWidget {
  final int? score;
  final VoidCallback onAssumir;
  final VoidCallback onCancelar;
  const _RecusadoView({required this.score, required this.onAssumir, required this.onCancelar});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.warning_rounded, color: AppColors.danger, size: 64),
      const SizedBox(height: 16),
      const Text('CLIENTE COM ALTO RISCO',
          style: TextStyle(fontSize: 18, color: AppColors.danger, fontWeight: FontWeight.w500)),
      if (score != null) ...[
        const SizedBox(height: 8),
        Text('Score: $score/100', style: const TextStyle(color: Colors.grey)),
      ],
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
          ActionButton(label: 'ASSUMIR RISCO',     onPressed: onAssumir,  color: AppColors.warning),
          const SizedBox(width: 12),
          ActionButton(label: 'CANCELAR',          onPressed: onCancelar, outlined: true, color: AppColors.danger),
        ],
      ),
    ],
  );
}

class _ErroView extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentar;
  const _ErroView({required this.mensagem, required this.onTentar});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
      const SizedBox(height: 12),
      Text(mensagem, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: onTentar, child: const Text('Tentar novamente')),
    ],
  );
}
