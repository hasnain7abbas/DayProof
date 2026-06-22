class DailyProofModel {
  DailyProofModel({
    required this.id,
    required this.date,
    required this.taskIds,
    required this.morningLocked,
    required this.nightReviewed,
    this.morningCompletedAt,
    this.nightCompletedAt,
    this.doneCount = 0,
    this.failedCount = 0,
    this.removedCount = 0,
  });

  final String id;
  final DateTime date;
  final List<String> taskIds;
  final bool morningLocked;
  final bool nightReviewed;
  final DateTime? morningCompletedAt;
  final DateTime? nightCompletedAt;
  final int doneCount;
  final int failedCount;
  final int removedCount;

  DailyProofModel copyWith({
    List<String>? taskIds,
    bool? morningLocked,
    bool? nightReviewed,
    DateTime? morningCompletedAt,
    DateTime? nightCompletedAt,
    int? doneCount,
    int? failedCount,
    int? removedCount,
  }) {
    return DailyProofModel(
      id: id,
      date: date,
      taskIds: taskIds ?? this.taskIds,
      morningLocked: morningLocked ?? this.morningLocked,
      nightReviewed: nightReviewed ?? this.nightReviewed,
      morningCompletedAt: morningCompletedAt ?? this.morningCompletedAt,
      nightCompletedAt: nightCompletedAt ?? this.nightCompletedAt,
      doneCount: doneCount ?? this.doneCount,
      failedCount: failedCount ?? this.failedCount,
      removedCount: removedCount ?? this.removedCount,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'taskIds': taskIds,
    'morningLocked': morningLocked,
    'nightReviewed': nightReviewed,
    'morningCompletedAt': morningCompletedAt?.toIso8601String(),
    'nightCompletedAt': nightCompletedAt?.toIso8601String(),
    'doneCount': doneCount,
    'failedCount': failedCount,
    'removedCount': removedCount,
  };

  factory DailyProofModel.fromMap(Map<dynamic, dynamic> map) {
    return DailyProofModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      taskIds: List<String>.from(map['taskIds'] as List? ?? const []),
      morningLocked: map['morningLocked'] == true,
      nightReviewed: map['nightReviewed'] == true,
      morningCompletedAt: map['morningCompletedAt'] == null
          ? null
          : DateTime.parse(map['morningCompletedAt'] as String),
      nightCompletedAt: map['nightCompletedAt'] == null
          ? null
          : DateTime.parse(map['nightCompletedAt'] as String),
      doneCount: (map['doneCount'] as num?)?.toInt() ?? 0,
      failedCount: (map['failedCount'] as num?)?.toInt() ?? 0,
      removedCount: (map['removedCount'] as num?)?.toInt() ?? 0,
    );
  }
}
