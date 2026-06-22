import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime dayKey(DateTime value) => DateTime(value.year, value.month, value.day);

String dayId(DateTime value) => DateFormat('yyyy-MM-dd').format(dayKey(value));

String readableDay(DateTime value) => DateFormat('EEEE, MMMM d').format(value);

String shortDay(DateTime value) => DateFormat('E').format(value);

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

DateTime dateWithTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
