import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/models/app_settings_model.dart';
import 'data/models/daily_proof_model.dart';
import 'data/models/task_model.dart';
import 'data/storage/local_storage_service.dart';
import 'features/history/history_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/today/home_screen.dart';
import 'features/today/morning_planning_screen.dart';
import 'features/today/night_review_screen.dart';
import 'services/notification_service.dart';

class DayProofApp extends StatefulWidget {
  const DayProofApp({
    super.key,
    required this.storage,
    required this.notifications,
  });

  final LocalStorageService storage;
  final NotificationService notifications;

  @override
  State<DayProofApp> createState() => _DayProofAppState();
}

class _DayProofAppState extends State<DayProofApp> {
  late final DayProofController controller;

  @override
  void initState() {
    super.initState();
    controller = DayProofController(widget.storage, widget.notifications);
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return DayProofScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DayProof',
        theme: AppTheme.dark(),
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (!controller.settings.onboardingCompleted) {
              return OnboardingScreen(controller: controller);
            }
            return NotificationRouteListener(
              controller: controller,
              child: DayProofHome(controller: controller),
            );
          },
        ),
      ),
    );
  }
}

class DayProofController extends ChangeNotifier {
  DayProofController(this.storage, this.notifications);

  final LocalStorageService storage;
  final NotificationService notifications;

  AppSettingsModel settings = AppSettingsModel.defaults();
  DailyProofModel todayProof = DailyProofModel(
    id: '',
    date: DateTime.now(),
    taskIds: const [],
    morningLocked: false,
    nightReviewed: false,
  );
  List<TaskModel> todayTasks = [];
  List<TaskModel> carryOvers = [];
  List<DailyProofModel> proofs = [];
  List<TaskModel> allTasks = [];
  int tabIndex = 0;
  DateTime activeDate = DateTime.now();
  String? notice;

  void load() {
    settings = storage.getSettings();
    _refresh();
    notifications.scheduleDaily(settings);
  }

  void _refresh() {
    todayProof = storage.proofFor(activeDate);
    todayTasks = storage.tasksForProof(todayProof);
    carryOvers = storage.carryOversFor(activeDate);
    proofs = storage.getAllProofs();
    allTasks = storage.getAllTasks();
    notifyListeners();
  }

  Future<void> completeOnboarding(AppSettingsModel next) async {
    settings = next.copyWith(onboardingCompleted: true);
    await storage.saveSettings(settings);
    await notifications.requestNotificationPermission();
    await notifications.scheduleDaily(settings);
    _refresh();
  }

  Future<void> updateSettings(
    AppSettingsModel next, {
    bool requestExactAlarm = false,
  }) async {
    settings = next;
    await storage.saveSettings(settings);
    if (settings.notificationsEnabled) {
      final allowed = await notifications.requestNotificationPermission();
      if (!allowed) {
        settings = settings.copyWith(notificationsEnabled: false);
        await storage.saveSettings(settings);
        notice = 'Reminders are off. You can still use DayProof manually.';
      }
      if (requestExactAlarm && settings.strongReminderMode) {
        final exactAllowed = await notifications.requestExactAlarmPermission();
        if (!exactAllowed) {
          settings = settings.copyWith(strongReminderMode: false);
          await storage.saveSettings(settings);
          notice =
              'Strong reminders are unavailable, so DayProof will use normal reminders.';
        }
      }
    }
    await notifications.scheduleDaily(settings);
    _refresh();
  }

  Future<String?> addTask(String title, {bool addedLater = false}) async {
    final clean = title.trim();
    if (clean.isEmpty) return 'Write the task first.';
    if (todayTasks.length >= settings.maxTasks) {
      return 'Too many tasks for today.';
    }
    await storage.createTask(clean, activeDate, addedLater: addedLater);
    _refresh();
    return null;
  }

  Future<void> editTask(TaskModel task, String title) async {
    if (title.trim().isEmpty) return;
    await storage.saveTask(task.copyWith(title: title.trim()));
    _refresh();
  }

  Future<void> removeTask(TaskModel task) async {
    await storage.removeTaskFromToday(task, activeDate);
    _refresh();
  }

  Future<void> lockToday(List<TaskModel> keptCarryOvers) async {
    if (todayTasks.isEmpty && keptCarryOvers.isEmpty) {
      notice = 'Nothing planned yet. Choose what would make today count.';
      notifyListeners();
      return;
    }
    await storage.lockToday(activeDate, keptCarryOvers);
    _refresh();
  }

  Future<void> review(TaskModel task, String status) async {
    await storage.reviewTask(task, status);
    _refresh();
  }

  Future<void> closeDay() async {
    await storage.closeDay(activeDate);
    _refresh();
  }

  Future<void> simulateNextDay() async {
    activeDate = activeDate.add(const Duration(days: 1));
    _refresh();
  }

  Future<void> resetToday() async {
    await storage.resetToday(activeDate);
    _refresh();
  }

  Future<void> clearAll() async {
    await storage.clearAll();
    settings = AppSettingsModel.defaults();
    activeDate = DateTime.now();
    _refresh();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }
}

class DayProofScope extends InheritedNotifier<DayProofController> {
  const DayProofScope({
    super.key,
    required DayProofController controller,
    required super.child,
  }) : super(notifier: controller);

  static DayProofController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DayProofScope>()!
        .notifier!;
  }
}

class DayProofHome extends StatelessWidget {
  const DayProofHome({super.key, required this.controller});

  final DayProofController controller;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(controller: controller),
      StatsScreen(controller: controller),
      HistoryScreen(controller: controller),
      SettingsScreen(controller: controller),
    ];
    return Scaffold(
      body: screens[controller.tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.tabIndex,
        onDestinationSelected: controller.setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class NotificationRouteListener extends StatefulWidget {
  const NotificationRouteListener({
    super.key,
    required this.controller,
    required this.child,
  });

  final DayProofController controller;
  final Widget child;

  @override
  State<NotificationRouteListener> createState() =>
      _NotificationRouteListenerState();
}

class _NotificationRouteListenerState extends State<NotificationRouteListener> {
  @override
  void initState() {
    super.initState();
    widget.controller.notifications.launchPayload.addListener(_openPayload);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPayload());
  }

  @override
  void didUpdateWidget(NotificationRouteListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.notifications != widget.controller.notifications) {
      oldWidget.controller.notifications.launchPayload.removeListener(
        _openPayload,
      );
      widget.controller.notifications.launchPayload.addListener(_openPayload);
    }
  }

  @override
  void dispose() {
    widget.controller.notifications.launchPayload.removeListener(_openPayload);
    super.dispose();
  }

  void _openPayload() {
    if (!mounted) return;
    final payload = widget.controller.notifications.consumeLaunchPayload();
    if (payload == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (payload) {
        case 'morning':
          DayProofRoutes.morning(context, widget.controller);
        case 'night':
          DayProofRoutes.night(context, widget.controller);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class DayProofRoutes {
  static Future<void> morning(
    BuildContext context,
    DayProofController controller,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MorningPlanningScreen(controller: controller),
      ),
    );
  }

  static Future<void> night(
    BuildContext context,
    DayProofController controller,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NightReviewScreen(controller: controller),
      ),
    );
  }
}
