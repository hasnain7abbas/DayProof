import 'package:dayproof/app.dart';
import 'package:dayproof/core/theme/app_theme.dart';
import 'package:dayproof/data/models/app_settings_model.dart';
import 'package:dayproof/data/models/daily_proof_model.dart';
import 'package:dayproof/data/models/task_model.dart';
import 'package:dayproof/data/storage/local_storage_service.dart';
import 'package:dayproof/features/settings/settings_screen.dart';
import 'package:dayproof/features/stats/stats_screen.dart';
import 'package:dayproof/features/today/home_screen.dart';
import 'package:dayproof/features/today/morning_planning_screen.dart';
import 'package:dayproof/features/today/night_review_screen.dart';
import 'package:dayproof/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render README screenshots', (tester) async {
    await binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => binding.setSurfaceSize(null));
    await _loadFonts();
    final controller = _fixtureController();

    await _capture(
      tester,
      HomeScreen,
      HomeScreen(controller: controller, now: DateTime(2026, 7, 2, 8)),
      '../docs/images/dayproof-today.png',
    );
    await _capture(
      tester,
      MorningPlanningScreen,
      MorningPlanningScreen(controller: controller),
      '../docs/images/dayproof-plan.png',
    );
    await _capture(
      tester,
      NightReviewScreen,
      NightReviewScreen(controller: controller),
      '../docs/images/dayproof-review.png',
    );
    await _capture(
      tester,
      StatsScreen,
      StatsScreen(controller: controller),
      '../docs/images/dayproof-stats.png',
    );
    await _capture(
      tester,
      SettingsScreen,
      SettingsScreen(controller: controller),
      '../docs/images/dayproof-settings.png',
    );
  });
}

Future<void> _loadFonts() async {
  final text = FontLoader('PlusJakartaSans')
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Variable.ttf'));
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([text.load(), icons.load()]);
}

Future<void> _capture(
  WidgetTester tester,
  Type screenType,
  Widget screen,
  String path,
) async {
  final screenshotKey = ValueKey(screenType);
  await tester.pumpWidget(
    RepaintBoundary(
      key: screenshotKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byKey(screenshotKey), matchesGoldenFile(path));
}

DayProofController _fixtureController() {
  final controller = DayProofController(
    LocalStorageService(),
    NotificationService(),
  );
  final today = DateTime(2026, 7, 2);
  final tasks = [
    _task('Finish experiment notes', today),
    _task('Call supervisor', today, carryCount: 1),
    _task('Clean data table', today, addedLater: true),
  ];

  controller
    ..settings = AppSettingsModel(
      morningTime: const TimeOfDay(hour: 8, minute: 0),
      nightTime: const TimeOfDay(hour: 22, minute: 0),
      onboardingCompleted: true,
      maxTasks: 7,
    )
    ..activeDate = today
    ..todayProof = DailyProofModel(
      id: 'today',
      date: today,
      taskIds: tasks.map((task) => task.id).toList(),
      morningLocked: true,
      nightReviewed: false,
    )
    ..todayTasks = tasks
    ..carryOvers = [
      _task(
        'Send email to professor',
        today.subtract(const Duration(days: 1)),
        status: 'failed',
        carryCount: 3,
      ),
    ]
    ..proofs = List.generate(7, (index) {
      final date = today.subtract(Duration(days: index));
      return DailyProofModel(
        id: 'proof-$index',
        date: date,
        taskIds: const [],
        morningLocked: true,
        nightReviewed: index != 0,
        doneCount: index == 0 ? 0 : 2 + (index % 2),
        failedCount: index == 0
            ? 0
            : index % 3 == 0
            ? 1
            : 0,
      );
    })
    ..allTasks = [
      ...tasks,
      _task('Prepare results figure', today, carryCount: 4),
    ];
  return controller;
}

TaskModel _task(
  String title,
  DateTime date, {
  String status = 'pending',
  int carryCount = 0,
  bool addedLater = false,
}) {
  return TaskModel(
    id: title,
    title: title,
    createdAt: date,
    status: status,
    carryCount: carryCount,
    assignedDate: date,
    addedLater: addedLater,
  );
}
