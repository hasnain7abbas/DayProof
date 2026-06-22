import '../../data/models/task_model.dart';

bool shouldPromptBreakdown(TaskModel task) => task.carryCount >= 3;

double completionRate(int done, int failed, int removed) {
  final total = done + failed + removed;
  if (total == 0) return 0;
  return done / total;
}

String closingLine(double rate) {
  if (rate >= 0.85) return 'Strong day. You kept your word.';
  if (rate >= 0.45) return 'Not perfect, but not wasted.';
  return 'Tomorrow starts with the truth.';
}
