import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/glass_card.dart';
import 'day_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  Widget build(BuildContext context) {
    final proofs = controller.proofs
        .where((proof) => proof.taskIds.isNotEmpty || proof.nightReviewed)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: proofs.isEmpty
          ? const EmptyState(
              title: 'No proof yet.',
              body: 'Finish one day and it will appear here.',
              icon: Icons.history_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: proofs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final proof = proofs[index];
                final total =
                    proof.doneCount + proof.failedCount + proof.removedCount;
                return GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(readableDay(proof.date)),
                    subtitle: Text(
                      total == 0
                          ? 'Proof not closed'
                          : proof.failedCount == 0
                          ? 'Perfect day'
                          : '${proof.doneCount}/$total completed, ${proof.failedCount} carried forward',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DayDetailScreen(
                          controller: controller,
                          proof: proof,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
