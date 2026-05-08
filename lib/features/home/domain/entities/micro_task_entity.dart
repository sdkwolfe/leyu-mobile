import 'package:leyu_mobile/features/home/domain/entities/micro_task_status_enum.dart';

import '../../data/models/micro_task.dart';

class MicroTaskEntity {
  final String id;
  final String? instruction;
  final String? audioUrl;
  final String? imageUrl;
  final String? text;
  final String? submissionAudioUrl;
  final String? submissionText;
  final List<String> rejectionReasons;
  final String? comment;
  final int currentRetry;
  final int allowedRetry;
  final MicroTaskStatus acceptanceStatus;
  final bool canRetry;

  MicroTaskEntity({
    required this.id,
    this.instruction,
    this.audioUrl,
    this.imageUrl,
    this.text,
    this.submissionAudioUrl,
    this.submissionText,
    this.rejectionReasons = const [],
    this.comment,
    this.currentRetry = 0,
    this.allowedRetry = 1,
    required this.acceptanceStatus,
    this.canRetry = false,
  });

  static MicroTaskEntity fromModel(MicroTask model) {
    print('Parsing MicroTaskEntity from model with id: ${model.id}');
    print(parseTaskStatus(model.acceptanceStatus));

    // Determine if filePath is an image based on file extension
    final filePath = model.filePath;

    return MicroTaskEntity(
      id: model.id,
      instruction: model.instruction,
      audioUrl:filePath,
      imageUrl:filePath,
      text: model.text,
      submissionAudioUrl: model.dataset?.filePath,
      submissionText: model.dataset?.textDataset,
      rejectionReasons: model.dataset?.rejectionReasons ?? [],
      comment: model.dataset?.comment,
      currentRetry: model.currentRetry ?? 0,
      allowedRetry: model.allowedRetry ?? 1,
      acceptanceStatus: parseTaskStatus(model.acceptanceStatus),
      canRetry: model.canRetry ??
          model.currentRetry != null &&
              (model.allowedRetry ?? 1) > (model.currentRetry ?? 0),
    );
  }
}
