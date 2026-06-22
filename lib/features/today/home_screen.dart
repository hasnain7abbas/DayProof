import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/primary_button.dart';
import 'morning_planning_screen.dart';
import 'night_review_screen.dart';
import 'widgets/proof_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  Widget build(BuildContext context) {
    final taskCount = controller.todayTasks.length;
    final carried = controller.carryOvers.length;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x221E3A8A),
              AppColors.background,
              Color(0x1914B8A6),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Good morning, Hasnain',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Today needs proof.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              ProofSummaryCard(controller: controller),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$taskCount tasks planned',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$carried carried over from yesterday',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        PrimaryButton(
                          label: 'Plan Today',
                          icon: Icons.edit_calendar_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MorningPlanningScreen(controller: controller),
                            ),
                          ),
                        ),
                        PrimaryButton(
                          label: 'Review Night',
                          icon: Icons.nightlight_round,
                          subtle: true,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  NightReviewScreen(controller: controller),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s proof',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (controller.todayTasks.isEmpty)
                      const EmptyState(
                        title: 'Nothing planned yet.',
                        body:
                            'Choose the few things that would make today count.',
                        icon: Icons.add_task_rounded,
                      )
                    else
                      ...controller.todayTasks.map(
                        (task) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            task.status == 'done'
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: task.status == 'done'
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          title: Text(task.title),
                          subtitle: task.addedLater
                              ? const Text('Added later')
                              : task.carryCount > 0
                              ? Text('Carried over ${task.carryCount} times')
                              : null,
                        ),
                      ),
                    const Divider(height: 24, color: AppColors.border),
                    Text(
                      'Morning reminder: ${formatTimeOfDay(controller.settings.morningTime)}',
                    ),
                    Text(
                      'Tonight’s review: ${formatTimeOfDay(controller.settings.nightTime)}',
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }
}
