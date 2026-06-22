import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_utils.dart';
import '../models/app_settings_model.dart';
import '../models/daily_proof_model.dart';
import '../models/task_model.dart';

class LocalStorageService {
  static const _tasksBoxName = 'tasks';
  static const _proofsBoxName = 'proofs';
  static const _settingsBoxName = 'settings';

  late Box _tasks;
  late Box _proofs;
  late Box _settings;
  final _uuid = const Uuid();

  Future<void> init() async {
    await Hive.initFlutter();
    _tasks = await Hive.openBox(_tasksBoxName);
    _proofs = await Hive.openBox(_proofsBoxName);
    _settings = await Hive.openBox(_settingsBoxName);
  }

  AppSettingsModel getSettings() {
    return AppSettingsModel.fromMap(_settings.get('app') as Map?);
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    await _settings.put('app', settings.toMap());
  }

  List<TaskModel> getAllTasks() {
    return _tasks.values
        .map((value) => TaskModel.fromMap(value as Map))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<DailyProofModel> getAllProofs() {
    return _proofs.values
        .map((value) => DailyProofModel.fromMap(value as Map))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DailyProofModel proofFor(DateTime date) {
    final id = dayId(date);
    final stored = _proofs.get(id);
    if (stored != null) return DailyProofModel.fromMap(stored as Map);
    return DailyProofModel(
      id: id,
      date: dayKey(date),
      taskIds: const [],
      morningLocked: false,
      nightReviewed: false,
    );
  }

  List<TaskModel> tasksForProof(DailyProofModel proof) {
    final all = getAllTasks();
    return proof.taskIds
        .map((id) => all.where((task) => task.id == id).firstOrNull)
        .whereType<TaskModel>()
        .toList();
  }

  List<TaskModel> carryOversFor(DateTime date) {
    final target = dayKey(date);
    return getAllTasks()
        .where(
          (task) =>
              task.status == 'failed' &&
              dayKey(task.assignedDate).isBefore(target),
        )
        .toList();
  }

  Future<TaskModel> createTask(
    String title,
    DateTime date, {
    bool addedLater = false,
    int carryCount = 0,
    DateTime? originalDate,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: DateTime.now(),
      status: 'pending',
      carryCount: carryCount,
      assignedDate: dayKey(date),
      originalDate: originalDate,
      addedLater: addedLater,
    );
    await saveTask(task);
    final proof = proofFor(date);
    await saveProof(proof.copyWith(taskIds: [...proof.taskIds, task.id]));
    return task;
  }

  Future<void> saveTask(TaskModel task) async {
    await _tasks.put(task.id, task.toMap());
  }

  Future<void> saveProof(DailyProofModel proof) async {
    await _proofs.put(proof.id, proof.toMap());
  }

  Future<void> removeTaskFromToday(TaskModel task, DateTime date) async {
    final proof = proofFor(date);
    await saveProof(
      proof.copyWith(
        taskIds: proof.taskIds.where((id) => id != task.id).toList(),
      ),
    );
    await saveTask(
      task.copyWith(status: 'removed', reviewedAt: DateTime.now()),
    );
  }

  Future<void> lockToday(DateTime date, List<TaskModel> keptCarryOvers) async {
    final proof = proofFor(date);
    final today = dayKey(date);
    final carriedIds = <String>[];
    for (final task in keptCarryOvers) {
      final carried = task.copyWith(
        status: 'pending',
        assignedDate: today,
        carryCount: task.carryCount + 1,
        originalDate: task.originalDate ?? task.assignedDate,
        clearCompletedAt: true,
        clearReviewedAt: true,
      );
      await saveTask(carried);
      carriedIds.add(carried.id);
    }
    final ids = <String>{...carriedIds, ...proof.taskIds}.toList();
    await saveProof(
      proof.copyWith(
        taskIds: ids,
        morningLocked: true,
        morningCompletedAt: DateTime.now(),
      ),
    );
  }

  Future<void> reviewTask(TaskModel task, String status) async {
    final now = DateTime.now();
    await saveTask(
      task.copyWith(
        status: status,
        reviewedAt: now,
        completedAt: status == 'done' ? now : null,
        clearCompletedAt: status != 'done',
      ),
    );
  }

  Future<void> closeDay(DateTime date) async {
    final proof = proofFor(date);
    final tasks = tasksForProof(proof);
    final done = tasks.where((task) => task.status == 'done').length;
    final failed = tasks.where((task) => task.status == 'failed').length;
    final removed = tasks.where((task) => task.status == 'removed').length;
    await saveProof(
      proof.copyWith(
        nightReviewed: true,
        nightCompletedAt: DateTime.now(),
        doneCount: done,
        failedCount: failed,
        removedCount: removed,
      ),
    );
  }

  Future<void> resetToday(DateTime date) async {
    final proof = proofFor(date);
    for (final task in tasksForProof(proof)) {
      await _tasks.delete(task.id);
    }
    await _proofs.delete(proof.id);
  }

  Future<void> clearAll() async {
    await _tasks.clear();
    await _proofs.clear();
    await _settings.clear();
  }

  String exportJson() {
    final payload = {
      'settings': getSettings().toMap(),
      'tasks': getAllTasks().map((task) => task.toMap()).toList(),
      'proofs': getAllProofs().map((proof) => proof.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  String databaseSummary() {
    return 'Tasks: ${_tasks.length}, proofs: ${_proofs.length}, settings: ${_settings.length}';
  }
}
