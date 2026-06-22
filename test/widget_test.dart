import 'package:dayproof/app.dart';
import 'package:dayproof/data/storage/local_storage_service.dart';
import 'package:dayproof/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DayProofController starts on the Today tab', () {
    final controller = DayProofController(
      LocalStorageService(),
      NotificationService(),
    );
    expect(controller.tabIndex, 0);
  });
}
