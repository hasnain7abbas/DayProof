import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/task_utils.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/primary_button.dart';
import 'widgets/task_card.dart';

class NightReviewScreen extends StatefulWidget {
  const NightReviewScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  State<NightReviewScreen> createState() => _NightReviewScreenState();
}

class _NightReviewScreenState extends State<NightReviewScreen> {
  late final ConfettiController confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  @override
  void dispose() {
    confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final active = c.todayTasks
            .where((task) => task.status != 'removed')
            .toList();
        final reviewed = active
            .where((task) => task.status != 'pending')
            .length;
        final complete = active.isNotEmpty && reviewed == active.length;
        final done = active.where((task) => task.status == 'done').length;
        final failed = active.where((task) => task.status == 'failed').length;
        final rate = active.isEmpty ? 0.0 : done / active.length;
        if (complete && failed == 0) confetti.play();

        return Scaffold(
          appBar: AppBar(title: const Text('Night review')),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.1,
                    colors: [Color(0x332A225A), AppColors.background],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Did you prove your day?',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No guilt. Just truth.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      if (active.isEmpty)
                        const EmptyState(
                          title: 'Nothing to review.',
                          body: 'Plan the day first, then come back tonight.',
                          icon: Icons.nightlight_round,
                        )
                      else ...[
                        ...active.map(
                          (task) => TaskCard(
                            task: task,
                            onDone: () => c.review(task, 'done'),
                            onFailed: () => c.review(task, 'failed'),
                            onRemove: () => c.review(task, 'removed'),
                          ),
                        ),
                        if (complete) ...[
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  closingLine(rate),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text('Today’s score: $done/${active.length}'),
                                Text('Completion: ${(rate * 100).round()}%'),
                                Text('Carried to tomorrow: $failed'),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  label: 'Close the day',
                                  icon: Icons.verified_rounded,
                                  onPressed: () async {
                                    await c.closeDay();
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                        ],
                      ],
                    ],
                  ).animate().fadeIn(duration: 260.ms),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: .03,
                  numberOfParticles: 18,
                  gravity: .18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
