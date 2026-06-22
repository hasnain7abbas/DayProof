import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import 'glass_card.dart';

class TimePickerTile extends StatelessWidget {
  const TimePickerTile({
    super.key,
    required this.label,
    required this.time,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Text(
          formatTimeOfDay(time),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (picked != null) onChanged(picked);
        },
      ),
    );
  }
}
