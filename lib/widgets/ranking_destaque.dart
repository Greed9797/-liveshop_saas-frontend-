import 'package:flutter/material.dart';

class RankingDestaque extends StatelessWidget {
  final List<Map<String, dynamic>> rankings;

  const RankingDestaque({super.key, required this.rankings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined, size: 24),
                SizedBox(width: 8),
                Text(
                  'FRANQUIAS EM DESTAQUE DO DIA',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
                SizedBox(width: 8),
                Icon(Icons.flag_outlined, size: 24),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildAvatar(
                    rankings[1], '2º LUGAR', 0.8), // 2nd place slightly smaller
                _buildAvatar(rankings[0], '1º LUGAR', 1.0), // 1st place
                _buildAvatar(rankings[2], '3º LUGAR', 0.8), // 3rd place
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.military_tech, color: Color(0xFFC0C0C0)), // Silver
                Icon(Icons.military_tech, color: Color(0xFFFFD700)), // Gold
                Icon(Icons.military_tech, color: Color(0xFFCD7F32)), // Bronze
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> data, String place, double scale) {
    return Column(
      children: [
        Container(
          width: 70 * scale,
          height: 70 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12, width: 2),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://i.pravatar.cc/150'), // Placeholder avatar
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            data['nome'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          place,
          style: const TextStyle(
              fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
