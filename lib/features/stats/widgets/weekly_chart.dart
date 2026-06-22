import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/daily_proof_model.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.proofs});

  final List<DailyProofModel> proofs;

  @override
  Widget build(BuildContext context) {
    final days = proofs.take(7).toList().reversed.toList();
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final proof = index < days.length ? days[index] : null;
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
                  Text(proof == null ? '-' : '${(rate * 100).round()}%'),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
