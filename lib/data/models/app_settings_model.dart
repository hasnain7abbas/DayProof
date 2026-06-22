import 'package:flutter/material.dart';

class AppSettingsModel {
  AppSettingsModel({
    required this.morningTime,
    required this.nightTime,
    this.notificationsEnabled = true,
    this.strongReminderMode = false,
    this.onboardingCompleted = false,
    this.maxTasks = 7,
    this.developerMode = false,
  });

  final TimeOfDay morningTime;
  final TimeOfDay nightTime;
  final bool notificationsEnabled;
  final bool strongReminderMode;
  final bool onboardingCompleted;
  final int maxTasks;
  final bool developerMode;

  AppSettingsModel copyWith({
    TimeOfDay? morningTime,
    TimeOfDay? nightTime,
    bool? notificationsEnabled,
    bool? strongReminderMode,
    bool? onboardingCompleted,
    int? maxTasks,
    bool? developerMode,
  }) {
    return AppSettingsModel(
      morningTime: morningTime ?? this.morningTime,
      nightTime: nightTime ?? this.nightTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      strongReminderMode: strongReminderMode ?? this.strongReminderMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      maxTasks: maxTasks ?? this.maxTasks,
      developerMode: developerMode ?? this.developerMode,
    );
  }

  Map<String, dynamic> toMap() => {
    'morningMinutes': morningTime.hour * 60 + morningTime.minute,
    'nightMinutes': nightTime.hour * 60 + nightTime.minute,
    'notificationsEnabled': notificationsEnabled,
    'strongReminderMode': strongReminderMode,
    'onboardingCompleted': onboardingCompleted,
    'maxTasks': maxTasks,
    'developerMode': developerMode,
  };

  factory AppSettingsModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return AppSettingsModel.defaults();
    final morning = (map['morningMinutes'] as num?)?.toInt() ?? 480;
    final night = (map['nightMinutes'] as num?)?.toInt() ?? 1320;
    return AppSettingsModel(
      morningTime: TimeOfDay(hour: morning ~/ 60, minute: morning % 60),
      nightTime: TimeOfDay(hour: night ~/ 60, minute: night % 60),
      notificationsEnabled: map['notificationsEnabled'] != false,
      strongReminderMode: map['strongReminderMode'] == true,
      onboardingCompleted: map['onboardingCompleted'] == true,
      maxTasks: (map['maxTasks'] as num?)?.toInt() ?? 7,
      developerMode: map['developerMode'] == true,
    );
  }

  factory AppSettingsModel.defaults() {
    return AppSettingsModel(
      morningTime: const TimeOfDay(hour: 8, minute: 0),
      nightTime: const TimeOfDay(hour: 22, minute: 0),
    );
  }
}
