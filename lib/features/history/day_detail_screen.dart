import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/daily_proof_model.dart';

class DayDetailScreen extends StatelessWidget {
  const DayDetailScreen({
    super.key,
    required this.controller,
    required this.proof,
  });

  final DayProofController controller;
  final DailyProofModel proof;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.storage.tasksForProof(proof);
    return Scaffold(
      appBar: AppBar(title: Text(readableDay(proof.date))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: tasks.map((task) {
          final icon = switch (task.status) {
            'done' => Icons.check_circle_rounded,
            'failed' => Icons.cancel_rounded,
            'removed' => Icons.archive_rounded,
            _ => Icons.radio_button_unchecked_rounded,
          };
          final color = switch (task.status) {
            'done' => AppColors.success,
            'failed' => AppColors.failure,
            'removed' => AppColors.textSecondary,
            _ => AppColors.primaryAccent,
          };
          return ListTile(
            leading: Icon(icon, color: color),
            title: Text(task.title),
            subtitle: Text(
              task.status == 'removed'
                  ? 'Removed'
                  : task.status == 'failed'
                  ? 'Carried forward'
                  : task.status,
            ),
          );
        }).toList(),
      ),
    );
  }
}
