import 'package:dayproof/data/models/task_model.dart';
import 'package:dayproof/features/today/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final task = TaskModel(
    id: 'task',
    title: 'Finish experiment notes',
    createdAt: DateTime(2026, 7, 2),
    status: 'pending',
    carryCount: 0,
    assignedDate: DateTime(2026, 7, 2),
  );

  testWidgets('planning card uses edit and remove icon actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(task: task, onEdit: () {}, onRemove: () {}),
        ),
      ),
    );

    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Remove'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    expect(find.text('Not Done'), findsNothing);
  });

  testWidgets('review card shows outcome actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onDone: () {},
            onFailed: () {},
            onRemove: () {},
          ),
        ),
      ),
    );

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Not Done'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });
}
