import '../../core/utils/date_utils.dart';
import '../../data/models/daily_proof_model.dart';
import '../../data/models/task_model.dart';

class StatsMetrics {
  StatsMetrics._({
    required this.reviewedProofs,
    required this.weeklyCompletion,
    required this.streak,
    required this.totalDone,
    required this.totalFailed,
    required this.totalRemoved,
    required this.bestDay,
    required this.mostCarriedTask,
  });

  final List<DailyProofModel> reviewedProofs;
  final int weeklyCompletion;
  final int streak;
  final int totalDone;
  final int totalFailed;
  final int totalRemoved;
  final String bestDay;
  final String mostCarriedTask;

  factory StatsMetrics.calculate({
    required List<DailyProofModel> proofs,
    required List<TaskModel> tasks,
    required DateTime activeDate,
  }) {
    final reviewed = proofs.where((proof) => proof.nightReviewed).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final today = dayKey(activeDate);
    final weekStart = today.subtract(const Duration(days: 6));
    final thisWeek = reviewed.where((proof) {
      final date = dayKey(proof.date);
      return !date.isBefore(weekStart) && !date.isAfter(today);
    });

    final weeklyDone = thisWeek.fold<int>(
      0,
      (sum, proof) => sum + proof.doneCount,
    );
    final weeklyTotal = thisWeek.fold<int>(
      0,
      (sum, proof) =>
          sum + proof.doneCount + proof.failedCount + proof.removedCount,
    );

    final reviewedDays = reviewed.map((proof) => dayId(proof.date)).toSet();
    var cursor = today;
    if (!reviewedDays.contains(dayId(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (reviewedDays.contains(dayId(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    DailyProofModel? best;
    for (final proof in reviewed) {
      if (best == null || proof.doneCount > best.doneCount) best = proof;
    }

    TaskModel? mostCarried;
    for (final task in tasks) {
      if (mostCarried == null || task.carryCount > mostCarried.carryCount) {
        mostCarried = task;
      }
    }

    return StatsMetrics._(
      reviewedProofs: List.unmodifiable(reviewed),
      weeklyCompletion: weeklyTotal == 0
          ? 0
          : (weeklyDone / weeklyTotal * 100).round(),
      streak: streak,
      totalDone: reviewed.fold(0, (sum, proof) => sum + proof.doneCount),
      totalFailed: reviewed.fold(0, (sum, proof) => sum + proof.failedCount),
      totalRemoved: reviewed.fold(0, (sum, proof) => sum + proof.removedCount),
      bestDay: best == null
          ? 'No proof yet'
          : '${best.doneCount}/${best.doneCount + best.failedCount + best.removedCount}',
      mostCarriedTask: mostCarried == null ? 'None yet' : mostCarried.title,
    );
  }
}
