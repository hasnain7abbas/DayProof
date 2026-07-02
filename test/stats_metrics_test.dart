import 'package:dayproof/data/models/daily_proof_model.dart';
import 'package:dayproof/data/models/task_model.dart';
import 'package:dayproof/features/stats/stats_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weekly completion excludes older proofs and streak stops at gaps', () {
    final activeDate = DateTime(2026, 7, 2);
    final proofs = [
      _proof(DateTime(2026, 7, 1), done: 2, failed: 1),
      _proof(DateTime(2026, 6, 30), done: 1, failed: 0),
      _proof(DateTime(2026, 6, 28), done: 1, failed: 1),
      _proof(DateTime(2026, 6, 20), done: 20, failed: 0),
    ];

    final metrics = StatsMetrics.calculate(
      proofs: proofs,
      tasks: [_task('Old task', carryCount: 1)],
      activeDate: activeDate,
    );

    expect(metrics.weeklyCompletion, 67);
    expect(metrics.streak, 2);
    expect(metrics.totalDone, 24);
    expect(
      metrics.reviewedProofs.map((proof) => proof.date),
      orderedEquals([
        DateTime(2026, 7, 1),
        DateTime(2026, 6, 30),
        DateTime(2026, 6, 28),
        DateTime(2026, 6, 20),
      ]),
    );
  });

  test('best day and most-carried task do not reorder source lists', () {
    final proofs = [
      _proof(DateTime(2026, 7, 1), done: 1, failed: 1),
      _proof(DateTime(2026, 7, 2), done: 3, failed: 0),
    ];
    final tasks = [
      _task('First', carryCount: 1),
      _task('Second', carryCount: 4),
    ];

    final metrics = StatsMetrics.calculate(
      proofs: proofs,
      tasks: tasks,
      activeDate: DateTime(2026, 7, 2),
    );

    expect(metrics.bestDay, '3/3');
    expect(metrics.mostCarriedTask, 'Second');
    expect(proofs.first.date, DateTime(2026, 7, 1));
    expect(tasks.first.title, 'First');
  });
}

DailyProofModel _proof(
  DateTime date, {
  required int done,
  required int failed,
}) {
  return DailyProofModel(
    id: date.toIso8601String(),
    date: date,
    taskIds: const [],
    morningLocked: true,
    nightReviewed: true,
    doneCount: done,
    failedCount: failed,
  );
}

TaskModel _task(String title, {required int carryCount}) {
  return TaskModel(
    id: title,
    title: title,
    createdAt: DateTime(2026, 7, 1),
    status: 'pending',
    carryCount: carryCount,
    assignedDate: DateTime(2026, 7, 1),
  );
}
