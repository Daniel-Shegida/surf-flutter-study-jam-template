import 'package:surf_practice_chat_flutter/features/chat/models/chat_image_image_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Data transfer object representing image chat message.
class ChatMessageImageDto extends ChatMessageDto {
  /// image urls.
  final ChatImageDto images;

  /// Constructor for [ChatMessageImageDto].
  ChatMessageImageDto({
    required ChatUserDto chatUserDto,
    required this.images,
    required String message,
    required DateTime createdDate,
  }) : super(
          chatUserDto: chatUserDto,
          message: message,
          createdDateTime: createdDate,
        );

  /// Named constructor for converting DTO from [StudyJamClient].
  ChatMessageImageDto.fromSJClient({
    required SjMessageDto sjMessageDto,
    required SjUserDto sjUserDto,
    required bool isUserLocal,
  })  : images = ChatImageDto(
          urls: sjMessageDto.images!,
        ),
        super(
          createdDateTime: sjMessageDto.created,
          message: sjMessageDto.text,
          chatUserDto: isUserLocal
              ? ChatUserLocalDto.fromSJClient(sjUserDto)
              : ChatUserDto.fromSJClient(sjUserDto),
        );

  @override
  String toString() =>
      'ChatMessageGeolocationDto(location: $images) extends ${super.toString()}';
}
