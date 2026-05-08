enum TaskType {
  Text_to_Speech,
  Speech_to_Text,
  Text_to_Text,
  Image_to_Text,
  Image_to_Speech,
  Other
}

TaskType parseTaskType(String? type) {
  switch (type) {
    case 'text-audio':
      return TaskType.Text_to_Speech;
    case 'audio-text':
      return TaskType.Speech_to_Text;
    case 'text-text':
      return TaskType.Text_to_Text;
    case 'image-text':
      return TaskType.Image_to_Text;
    case 'image-audio':
      return TaskType.Image_to_Speech;
    default:
      return TaskType.Other;
  }
}
