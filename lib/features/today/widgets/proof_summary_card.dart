import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/task_utils.dart';
import '../../../shared/widgets/glass_card.dart';

class ProofSummaryCard extends StatelessWidget {
  const ProofSummaryCard({super.key, required this.controller});

  final DayProofController controller;

  @override
  Widget build(BuildContext context) {
    final proof = controller.todayProof;
    final total = proof.doneCount + proof.failedCount + proof.removedCount;
    final rate = completionRate(
      proof.doneCount,
      proof.failedCount,
      proof.removedCount,
    );
    if (proof.nightReviewed) {
      return GlassCard(
        child: Row(
          children: [
            const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 34,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day closed.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${proof.doneCount} done, ${proof.failedCount} carried forward. Completion: ${(rate * 100).round()}%',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return GlassCard(
      child: Row(
        children: [
          Icon(
            proof.morningLocked
                ? Icons.lock_rounded
                : Icons.wb_twilight_rounded,
            color: proof.morningLocked
                ? AppColors.primaryAccent
                : AppColors.secondaryAccent,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proof.morningLocked ? 'Proof locked.' : 'Proof still open.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  total == 0
                      ? 'Choose only what matters.'
                      : '$total decisions recorded tonight.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
