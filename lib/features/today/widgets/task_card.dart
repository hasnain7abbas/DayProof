import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/glass_card.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onDone,
    this.onFailed,
    this.onRemove,
    this.onEdit,
  });

  final TaskModel task;
  final VoidCallback? onDone;
  final VoidCallback? onFailed;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                ),
            ],
          ),
          if (task.addedLater || task.carryCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              task.addedLater
                  ? 'Added later'
                  : 'Carried over ${task.carryCount} times',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (onDone != null || onFailed != null || onRemove != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionChip(
                  label: 'Done',
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  selected: task.status == 'done',
                  onTap: onDone,
                ),
                _ActionChip(
                  label: 'Not Done',
                  icon: Icons.close_rounded,
                  color: AppColors.failure,
                  selected: task.status == 'failed',
                  onTap: onFailed,
                ),
                _ActionChip(
                  label: 'Remove',
                  icon: Icons.archive_rounded,
                  color: AppColors.textSecondary,
                  selected: task.status == 'removed',
                  onTap: onRemove,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? AppColors.background : color,
      ),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected ? color : AppColors.cardHigh,
      labelStyle: TextStyle(
        color: selected ? AppColors.background : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? color : AppColors.border),
    );
  }
}
