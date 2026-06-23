import 'dart:io';

import 'package:dayproof/core/utils/date_utils.dart';
import 'package:dayproof/data/storage/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService storage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('dayproof_test_');
    storage = LocalStorageService();
    await storage.init(path: tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('kept carry-over creates a fresh task for the new day', () async {
    final firstDay = DateTime(2026, 6, 22);
    final secondDay = firstDay.add(const Duration(days: 1));

    final original = await storage.createTask('Finish graph labels', firstDay);
    await storage.lockToday(firstDay, const []);
    await storage.reviewTask(original, 'failed');
    await storage.closeDay(firstDay);

    final carryOvers = storage.carryOversFor(secondDay);
    expect(carryOvers, hasLength(1));

    await storage.lockToday(secondDay, carryOvers);

    final firstProofTasks = storage.tasksForProof(storage.proofFor(firstDay));
    final secondProofTasks = storage.tasksForProof(storage.proofFor(secondDay));

    expect(firstProofTasks, hasLength(1));
    expect(firstProofTasks.single.id, original.id);
    expect(firstProofTasks.single.status, 'failed');
    expect(dayId(firstProofTasks.single.assignedDate), dayId(firstDay));

    expect(secondProofTasks, hasLength(1));
    expect(secondProofTasks.single.id, isNot(original.id));
    expect(secondProofTasks.single.title, original.title);
    expect(secondProofTasks.single.status, 'pending');
    expect(secondProofTasks.single.carryCount, 1);
    expect(dayId(secondProofTasks.single.assignedDate), dayId(secondDay));
    expect(dayId(secondProofTasks.single.originalDate!), dayId(firstDay));
    expect(secondProofTasks.single.previousTaskId, original.id);
    expect(storage.carryOversFor(secondDay), isEmpty);
  });
}
