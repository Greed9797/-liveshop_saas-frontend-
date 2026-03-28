import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Card de cabine com indicador pulsante se AO VIVO
class CabineCard extends StatefulWidget {
  final Map<String, dynamic> cabine;
  final VoidCallback? onTap;
  const CabineCard({super.key, required this.cabine, this.onTap});

  @override
  State<CabineCard> createState() => _CabineCardState();
}

class _CabineCardState extends State<CabineCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  bool get isLive => widget.cabine['status'] == 'ao_vivo';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLive ? AppColors.success : const Color(0xFFE0E0E0),
            width: isLive ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cabine ${widget.cabine['numero']}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                if (isLive)
                  FadeTransition(
                    opacity: _pulse,
                    child: const Icon(Icons.circle, color: AppColors.success, size: 10),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            StatusBadge(status: widget.cabine['status'] as String),
            if (isLive) ...[
              const SizedBox(height: 6),
              Text(widget.cabine['apresentador'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(widget.cabine['cliente'] ?? '',      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }
}
