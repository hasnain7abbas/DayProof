import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/time_picker_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int versionTaps = 0;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final s = c.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: c,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TimePickerTile(
              label: 'Morning reminder time',
              time: s.morningTime,
              onChanged: (time) =>
                  c.updateSettings(s.copyWith(morningTime: time)),
            ),
            const SizedBox(height: 12),
            TimePickerTile(
              label: 'Night review time',
              time: s.nightTime,
              onChanged: (time) =>
                  c.updateSettings(s.copyWith(nightTime: time)),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notifications'),
                    subtitle: Text(
                      s.notificationsEnabled
                          ? 'DayProof can call you back to your day.'
                          : 'Reminders are off. You can still use DayProof manually.',
                    ),
                    value: s.notificationsEnabled,
                    onChanged: (value) => c.updateSettings(
                      s.copyWith(notificationsEnabled: value),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Strong reminder mode'),
                    subtitle: const Text(
                      'DayProof needs reminder permission so it can remind you exactly when you choose. Without it, reminders may arrive a little late depending on your phone settings.',
                    ),
                    value: s.strongReminderMode,
                    onChanged: (value) => c.updateSettings(
                      s.copyWith(strongReminderMode: value),
                      requestExactAlarm: value,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Max tasks per day'),
                    subtitle: Slider(
                      min: 3,
                      max: 7,
                      divisions: 4,
                      label: '${s.maxTasks}',
                      value: s.maxTasks.toDouble(),
                      onChanged: (value) =>
                          c.updateSettings(s.copyWith(maxTasks: value.round())),
                    ),
                    trailing: Text('${s.maxTasks}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ios_share_rounded),
                    title: const Text('Export data as JSON'),
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: c.storage.exportJson()),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('JSON copied to clipboard.'),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: const Text('Reset onboarding'),
                    onTap: () => c.updateSettings(
                      s.copyWith(onboardingCompleted: false),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_forever_rounded),
                    title: const Text('Clear all data'),
                    onTap: () => _confirmClear(context),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About DayProof'),
                    subtitle: const Text(
                      'Prove your day before it disappears.',
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        versionTaps++;
                        if (versionTaps >= 7) {
                          c.updateSettings(s.copyWith(developerMode: true));
                        }
                      },
                      child: const Text('1.0.0'),
                    ),
                  ),
                ],
              ),
            ),
            if (s.developerMode) ...[
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Test Mode',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _DevTile(
                      label: 'Trigger morning notification now',
                      onTap: () => c.notifications.showNow(
                        id: 2001,
                        title: 'DayProof',
                        body: 'Choose what matters today.',
                        payload: 'morning',
                      ),
                    ),
                    _DevTile(
                      label: 'Trigger night notification now',
                      onTap: () => c.notifications.showNow(
                        id: 2002,
                        title: 'DayProof Review',
                        body: 'Did you do what you promised yourself?',
                        payload: 'night',
                      ),
                    ),
                    _DevTile(
                      label: 'Simulate next day',
                      onTap: c.simulateNextDay,
                    ),
                    _DevTile(label: 'Reset today only', onTap: c.resetToday),
                    _DevTile(
                      label: 'Print local database summary',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(c.storage.databaseSummary())),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Morning: ${formatTimeOfDay(s.morningTime)}  •  Night: ${formatTimeOfDay(s.nightTime)}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear everything?'),
        content: const Text(
          'This will erase all tasks, history, and stats. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear everything'),
          ),
        ],
      ),
    );
    if (clear == true) await widget.controller.clearAll();
  }
}

class _DevTile extends StatelessWidget {
  const _DevTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
