import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class ReprovarModal extends StatefulWidget {
  const ReprovarModal({super.key});

  @override
  State<ReprovarModal> createState() => _ReprovarModalState();
}

class _ReprovarModalState extends State<ReprovarModal> {
  static const quickReasons = [
    'Restrição no CNPJ',
    'Documento inconsistente',
    'Política interna',
  ];

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _controller.text.trim().length >= 8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.dangerRed),
                  const SizedBox(width: 12),
                  Text('Reprovar Operação', style: AppTypography.h3),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Informe o motivo da restrição para manter a auditoria clara e auditável.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickReasons
                    .map((reason) => ActionChip(
                          label: Text(reason),
                          onPressed: () {
                            _controller.text = reason;
                            setState(() {});
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText:
                      'Descreva a razão da restrição comercial ou cadastral.',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canSubmit
                          ? () =>
                              Navigator.of(context).pop(_controller.text.trim())
                          : null,
                      child: const Text('Confirmar Restrição'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
