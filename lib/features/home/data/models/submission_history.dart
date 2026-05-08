class SubmissionHistory {
  final String id;
  final String code;
  final String? textDataSet;
  final String status;
  final bool isTest;
  final bool isFlagged;
  final double? audioDuration;
  final String? filePath;
  final String type;
  final String createdDate;
  final String? annotation;
  final String microTaskId;
  final List<RejectionReason> rejectionReasons;

  SubmissionHistory({
    required this.id,
    required this.code,
    this.textDataSet,
    required this.status,
    required this.isTest,
    required this.isFlagged,
    this.audioDuration,
    this.filePath,
    required this.type,
    required this.createdDate,
    this.annotation,
    required this.microTaskId,
    this.rejectionReasons = const [],
  });

  factory SubmissionHistory.fromJson(Map<String, dynamic> json) {
    return SubmissionHistory(
      id: json['id'] as String,
      code: json['code'] as String,
      textDataSet: json['text_data_set'] as String?,
      status: json['status'] as String,
      isTest: json['is_test'] as bool,
      isFlagged: json['is_flagged'] as bool,
      audioDuration: json['audio_duration'] != null
          ? (json['audio_duration'] as num).toDouble()
          : null,
      filePath: json['file_path'] as String?,
      type: json['type'] as String,
      createdDate: json['created_date'] as String,
      annotation: json['annotation'] as String?,
      microTaskId: json['micro_task_id'] as String,
      rejectionReasons: (json['rejectionReasons'] as List<dynamic>?)
              ?.map((e) => RejectionReason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RejectionReason {
  final String id;
  final String reason;
  final String comment;
  final String createdDate;

  RejectionReason({
    required this.id,
    required this.reason,
    required this.comment,
    required this.createdDate,
  });

  factory RejectionReason.fromJson(Map<String, dynamic> json) {
    return RejectionReason(
      id: json['id'] as String,
      reason: json['reason'] as String,
      comment: json['comment'] as String? ?? "",
      createdDate: json['created_date'] as String,
    );
  }
}
