import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pin do mapa por status do cliente
class ClientPin extends StatelessWidget {
  final String status;
  final String nome;
  const ClientPin({super.key, required this.status, required this.nome});

  Color get _color => switch (status) {
    'ativo'        => AppColors.success,
    'enviado'      => AppColors.warning,
    'negociacao'   => AppColors.info,
    'inadimplente' => AppColors.danger,
    'recomendacao' => AppColors.lilac,
    _              => Colors.grey,
  };

  IconData get _icon => status == 'recomendacao'
      ? Icons.diamond_outlined
      : Icons.location_on;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(nome, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
        ),
        Icon(_icon, color: _color, size: 28),
      ],
    );
  }
}
