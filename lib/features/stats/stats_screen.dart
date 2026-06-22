import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import 'widgets/weekly_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  Widget build(BuildContext context) {
    final reviewed = controller.proofs
        .where((proof) => proof.nightReviewed)
        .toList();
    final totalDone = reviewed.fold<int>(
      0,
      (sum, proof) => sum + proof.doneCount,
    );
    final totalFailed = reviewed.fold<int>(
      0,
      (sum, proof) => sum + proof.failedCount,
    );
    final totalRemoved = reviewed.fold<int>(
      0,
      (sum, proof) => sum + proof.removedCount,
    );
    final total = totalDone + totalFailed + totalRemoved;
    final completion = total == 0 ? 0 : (totalDone / total * 100).round();
    final streak = _reviewStreak(reviewed);
    final mostCarried = controller.allTasks.toList()
      ..sort((a, b) => b.carryCount.compareTo(a.carryCount));

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Proof over time',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.22,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _StatCard(label: 'This week', value: '$completion%'),
              _StatCard(label: 'Current streak', value: '$streak days'),
              _StatCard(label: 'Tasks completed', value: '$totalDone'),
              _StatCard(label: 'Tasks carried', value: '$totalFailed'),
            ],
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly rhythm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                WeeklyChart(proofs: reviewed),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signals', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text('Total failed tasks: $totalFailed'),
                Text('Total removed tasks: $totalRemoved'),
                Text('Best day: ${_bestDay(reviewed)}'),
                Text(
                  'Most carried task: ${mostCarried.isEmpty ? 'None yet' : mostCarried.first.title}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _reviewStreak(List proofs) {
    var streak = 0;
    for (final proof in proofs) {
      if (proof.nightReviewed) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _bestDay(List proofs) {
    if (proofs.isEmpty) return 'No proof yet';
    proofs.sort((a, b) => b.doneCount.compareTo(a.doneCount));
    final best = proofs.first;
    return '${best.doneCount}/${best.doneCount + best.failedCount + best.removedCount}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.secondaryAccent,
            ),
          ),
        ],
      ),
    );
  }
}
