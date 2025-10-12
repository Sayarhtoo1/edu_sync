import 'package:flutter/material.dart';

class TopPerformersWidget extends StatelessWidget {
  final List<Map<String, dynamic>> performers;

  const TopPerformersWidget({super.key, required this.performers});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Performers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: performers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final performer = performers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(performer['student_name']),
                  trailing: Text(
                    '${performer['percentage'].toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey;
    if (index == 2) return Colors.brown;
    return Colors.blue;
  }
}
