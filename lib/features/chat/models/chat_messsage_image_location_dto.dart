import 'package:surf_practice_chat_flutter/features/chat/models/chat_geolocation_geolocation_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_image_image_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Data transfer object representing geolocation and image chat message.
class ChatMessageImageLocationDto extends ChatMessageDto {
  /// image urls.
  final ChatImageDto images;

  /// Location point.
  final ChatGeolocationDto location;

  /// Constructor for [ChatMessageImageLocationDto].
  ChatMessageImageLocationDto({
    required ChatUserDto chatUserDto,
    required this.images,
    required this.location,
    required String message,
    required DateTime createdDate,
  }) : super(
          chatUserDto: chatUserDto,
          message: message,
          createdDateTime: createdDate,
        );

  /// Named constructor for converting DTO from [StudyJamClient].
  ChatMessageImageLocationDto.fromSJClient({
    required SjMessageDto sjMessageDto,
    required SjUserDto sjUserDto,
  })  : images = ChatImageDto(
          urls: sjMessageDto.images!,
        ),
        location = ChatGeolocationDto.fromGeoPoint(sjMessageDto.geopoint!),
        super(
          createdDateTime: sjMessageDto.created,
          message: sjMessageDto.text,
          chatUserDto: ChatUserDto.fromSJClient(sjUserDto),
        );

  @override
  String toString() =>
      'ChatMessageGeolocationDto(location: $images) extends ${super.toString()}';
}
