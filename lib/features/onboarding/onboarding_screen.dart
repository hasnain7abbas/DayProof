import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/app_settings_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/time_picker_tile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final DayProofController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  late TimeOfDay morning = widget.controller.settings.morningTime;
  late TimeOfDay night = widget.controller.settings.nightTime;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Intro(
        title: 'Your day needs proof.',
        body:
            'Every morning, choose what truly matters. Every night, check whether you protected your day.',
        button: 'Start',
      ),
      _TimePage(
        title: 'Pick your morning time.',
        child: TimePickerTile(
          label: 'Morning reminder',
          subtitle: 'DayProof will call you back to what matters.',
          time: morning,
          onChanged: (value) => setState(() => morning = value),
        ),
      ),
      _TimePage(
        title: 'Pick your night review time.',
        child: TimePickerTile(
          label: 'Night review',
          subtitle: 'Close the day honestly before it disappears.',
          time: night,
          onChanged: (value) => setState(() => night = value),
        ),
      ),
      _Intro(
        title: 'Keep it small. Keep it real.',
        body:
            'DayProof works best with 3 to 5 important tasks. Not everything belongs here. Only what matters.',
        button: 'Enter DayProof',
      ),
    ];
    final buttons = ['Start', 'Continue', 'Continue', 'Enter DayProof'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.1,
            colors: [Color(0x3322D3EE), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DayProof',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: controller,
                    onPageChanged: (value) => setState(() => page = value),
                    children: pages,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${page + 1}/4',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: buttons[page],
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () async {
                        if (page == 3) {
                          await widget.controller.completeOnboarding(
                            AppSettingsModel(
                              morningTime: morning,
                              nightTime: night,
                              onboardingCompleted: true,
                            ),
                          );
                        } else {
                          await controller.nextPage(
                            duration: 260.ms,
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.title, required this.body, required this.button});

  final String title;
  final String body;
  final String button;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ).animate().fadeIn(duration: 360.ms).slideY(begin: .06, end: 0),
    );
  }
}

class _TimePage extends StatelessWidget {
  const _TimePage({required this.title, required this.child});

  final String title;
  final Widget child;
  String get button => 'Continue';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 26),
          child,
        ],
      ).animate().fadeIn(duration: 360.ms).slideY(begin: .06, end: 0),
    );
  }
}
