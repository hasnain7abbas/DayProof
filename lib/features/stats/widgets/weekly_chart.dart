import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/daily_proof_model.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.proofs, required this.endDate});

  final List<DailyProofModel> proofs;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    final proofsByDay = {for (final proof in proofs) dayId(proof.date): proof};
    final end = dayKey(endDate);
    final days = List.generate(
      7,
      (index) => end.subtract(Duration(days: 6 - index)),
    );
    return SizedBox(
      height: 144,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final date = days[index];
          final proof = proofsByDay[dayId(date)];
          final total = proof == null
              ? 0
              : proof.doneCount + proof.failedCount + proof.removedCount;
          final rate = total == 0 ? 0.06 : proof!.doneCount / total;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: rate.clamp(.06, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primaryAccent,
                                AppColors.secondaryAccent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shortDay(date).substring(0, 1),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
