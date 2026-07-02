import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import 'stats_metrics.dart';
import 'widgets/weekly_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = StatsMetrics.calculate(
      proofs: controller.proofs,
      tasks: controller.allTasks,
      activeDate: controller.activeDate,
    );

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
              _StatCard(
                label: 'This week',
                value: '${metrics.weeklyCompletion}%',
              ),
              _StatCard(
                label: 'Current streak',
                value: '${metrics.streak} days',
              ),
              _StatCard(
                label: 'Tasks completed',
                value: '${metrics.totalDone}',
              ),
              _StatCard(
                label: 'Tasks carried',
                value: '${metrics.totalFailed}',
              ),
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
                WeeklyChart(
                  proofs: metrics.reviewedProofs,
                  endDate: controller.activeDate,
                ),
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
                Text('Total failed tasks: ${metrics.totalFailed}'),
                Text('Total removed tasks: ${metrics.totalRemoved}'),
                Text('Best day: ${metrics.bestDay}'),
                Text('Most carried task: ${metrics.mostCarriedTask}'),
              ],
            ),
          ),
        ],
      ),
    );
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
