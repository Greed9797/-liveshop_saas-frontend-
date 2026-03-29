import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class CabineCard extends StatefulWidget {
  final Map<String, dynamic> cabine;
  final VoidCallback? onTap;
  const CabineCard({super.key, required this.cabine, this.onTap});

  @override
  State<CabineCard> createState() => _CabineCardState();
}

class _CabineCardState extends State<CabineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get isLive => widget.cabine['status'] == 'ao_vivo';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive
                ? AppColors.success.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: isLive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cabine ${widget.cabine['numero']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (isLive)
                  FadeTransition(
                    opacity: _pulse,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            StatusBadge(status: widget.cabine['status'] as String),
            if (isLive) ...[
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.cabine['viewer_count'] ?? 0}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
              Text(
                'R\$ ${(widget.cabine['gmv_atual'] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
