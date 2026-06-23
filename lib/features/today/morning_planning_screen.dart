import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/primary_button.dart';
import 'widgets/carry_over_card.dart';
import 'widgets/task_card.dart';

class MorningPlanningScreen extends StatefulWidget {
  const MorningPlanningScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  State<MorningPlanningScreen> createState() => _MorningPlanningScreenState();
}

class _MorningPlanningScreenState extends State<MorningPlanningScreen> {
  final input = TextEditingController();
  final kept = <String>{};

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final planned = c.todayTasks;
        return Scaffold(
          appBar: AppBar(title: const Text('Morning proof')),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x2222D3EE), AppColors.background],
              ),
            ),
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Choose only what matters.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 14),
                  GlassCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: input,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'What must be done today?',
                          ),
                          onSubmitted: (_) => _addTask(context),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                planned.length >= 5
                                    ? 'This app works better when the list is small. Add only what truly matters.'
                                    : '${planned.length}/${c.settings.maxTasks} tasks',
                              ),
                            ),
                            PrimaryButton(
                              label: 'Add task',
                              icon: Icons.add_rounded,
                              onPressed: () => _addTask(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (c.carryOvers.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Still waiting from yesterday',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...c.carryOvers.map(
                      (task) => CarryOverCard(
                        task: task,
                        kept: kept.contains(task.id),
                        onKeep: () => setState(() {
                          kept.contains(task.id)
                              ? kept.remove(task.id)
                              : kept.add(task.id);
                        }),
                        onRemove: () => c.removeTask(task),
                        onBreakDown: () {
                          input.text = task.title;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Rewrite it as the next smallest step.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Today', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  if (planned.isEmpty)
                    Text(
                      'Nothing planned yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...planned.map(
                      (task) => TaskCard(
                        task: task,
                        onEdit: () => _editTask(context, task),
                        onRemove: () => c.removeTask(task),
                      ),
                    ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: c.todayProof.morningLocked
                        ? "Today's proof is locked"
                        : "Lock today's proof",
                    icon: Icons.lock_rounded,
                    onPressed: c.todayProof.morningLocked
                        ? null
                        : () async {
                            final keepTasks = c.carryOvers
                                .where((task) => kept.contains(task.id))
                                .toList();
                            await c.lockToday(keepTasks);
                            if (context.mounted) Navigator.pop(context);
                          },
                  ),
                ],
              ).animate().fadeIn(duration: 260.ms),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addTask(BuildContext context) async {
    final error = await widget.controller.addTask(
      input.text,
      addedLater: widget.controller.todayProof.morningLocked,
    );
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      input.clear();
    }
  }

  Future<void> _editTask(BuildContext context, TaskModel task) async {
    final edit = TextEditingController(text: task.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit task'),
        content: TextField(controller: edit, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, edit.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    edit.dispose();
    if (result != null) await widget.controller.editTask(task, result);
  }
}
