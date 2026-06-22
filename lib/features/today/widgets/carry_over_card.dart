import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/task_utils.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/glass_card.dart';

class CarryOverCard extends StatelessWidget {
  const CarryOverCard({
    super.key,
    required this.task,
    required this.kept,
    required this.onKeep,
    required this.onRemove,
    required this.onBreakDown,
  });

  final TaskModel task;
  final bool kept;
  final VoidCallback onKeep;
  final VoidCallback onRemove;
  final VoidCallback onBreakDown;

  @override
  Widget build(BuildContext context) {
    final needsBreak = shouldPromptBreakdown(task);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            task.carryCount == 0
                ? 'Still waiting from yesterday'
                : 'Carried over ${task.carryCount} times',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (needsBreak) ...[
            const SizedBox(height: 10),
            Text(
              'This task has survived 3 days. Break it smaller or remove it.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: Icon(
                  kept
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  color: kept ? AppColors.background : AppColors.success,
                ),
                label: Text(kept ? 'Kept' : 'Keep'),
                onPressed: onKeep,
                backgroundColor: kept ? AppColors.success : AppColors.cardHigh,
              ),
              if (needsBreak)
                ActionChip(
                  avatar: const Icon(
                    Icons.call_split_rounded,
                    color: AppColors.secondaryAccent,
                  ),
                  label: const Text('Break smaller'),
                  onPressed: onBreakDown,
                  backgroundColor: AppColors.cardHigh,
                ),
              ActionChip(
                avatar: const Icon(
                  Icons.archive_rounded,
                  color: AppColors.failure,
                ),
                label: const Text('Remove'),
                onPressed: onRemove,
                backgroundColor: AppColors.cardHigh,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
