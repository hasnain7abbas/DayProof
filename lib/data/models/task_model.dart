class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.status,
    required this.carryCount,
    required this.assignedDate,
    this.completedAt,
    this.reviewedAt,
    this.originalDate,
    this.previousTaskId,
    this.addedLater = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? reviewedAt;
  final String status;
  final int carryCount;
  final DateTime assignedDate;
  final DateTime? originalDate;
  final String? previousTaskId;
  final bool addedLater;

  TaskModel copyWith({
    String? title,
    DateTime? completedAt,
    DateTime? reviewedAt,
    String? status,
    int? carryCount,
    DateTime? assignedDate,
    DateTime? originalDate,
    String? previousTaskId,
    bool? addedLater,
    bool clearCompletedAt = false,
    bool clearReviewedAt = false,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      reviewedAt: clearReviewedAt ? null : reviewedAt ?? this.reviewedAt,
      status: status ?? this.status,
      carryCount: carryCount ?? this.carryCount,
      assignedDate: assignedDate ?? this.assignedDate,
      originalDate: originalDate ?? this.originalDate,
      previousTaskId: previousTaskId ?? this.previousTaskId,
      addedLater: addedLater ?? this.addedLater,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'status': status,
    'carryCount': carryCount,
    'assignedDate': assignedDate.toIso8601String(),
    'originalDate': originalDate?.toIso8601String(),
    'previousTaskId': previousTaskId,
    'addedLater': addedLater,
  };

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt'] as String),
      reviewedAt: map['reviewedAt'] == null
          ? null
          : DateTime.parse(map['reviewedAt'] as String),
      status: map['status'] as String,
      carryCount: (map['carryCount'] as num?)?.toInt() ?? 0,
      assignedDate: DateTime.parse(map['assignedDate'] as String),
      originalDate: map['originalDate'] == null
          ? null
          : DateTime.parse(map['originalDate'] as String),
      previousTaskId: map['previousTaskId'] as String?,
      addedLater: map['addedLater'] == true,
    );
  }
}
