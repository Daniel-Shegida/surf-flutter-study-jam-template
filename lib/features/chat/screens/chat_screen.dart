import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_geolocation_geolocation_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_image_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_location_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_messsage_image_location_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/location_repository.dart';
import 'package:surf_practice_chat_flutter/features/utils/color_utils.dart';

/// Main screen of chat app, containing messages.
class ChatScreen extends StatefulWidget {
  /// Repository for chat functionality.
  final IChatRepository chatRepository;
  final ILocationRepository locationRepository;
  final String topicName;


  /// Constructor for [ChatScreen].
  const ChatScreen({
    required this.chatRepository,
    required this.locationRepository,
    required this.topicName,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _textController;

  bool isLocationMessage = false;

  bool isImageSaving = false;

  /// todo: change to list max 10
  String? images;

  Iterable<ChatMessageDto> _currentMessages = [];

  @override
  void initState() {
    _textController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _ChatAppBar(
          onUpdatePressed: _onUpdatePressed,
          topicName: widget.topicName,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ChatBody(
              messages: _currentMessages,
            ),
          ),
          _ChatTextField(
            onSendPressed: _onSendPressed,
            isLocationMessage: isLocationMessage,
            onGeoPressed: _onGeoPressed,
            isImageSaving: isImageSaving,
            onImagePressed: _onImagePressed,
            controller: _textController,
          ),
        ],
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final messages = await widget.chatRepository.getMessages();
    setState(() {
      _currentMessages = messages;
    });
  }

  Future<void> _onSendPressed(String messageText) async {
    if (isImageSaving) {
      images = messageText;
      setState(() {
        isImageSaving = !isImageSaving;
      });
    } else {
      final messages = await _sendMessage(messageText);
      setState(() {
        _currentMessages = messages;
      });
    }
  }

  /// todo(tester-dono): move it to logic things
  Future<Iterable<ChatMessageDto>> _sendMessage(String messageText) async {
    if ((images != null) && isLocationMessage) {
      final location = await widget.locationRepository.determinePosition();
      return widget.chatRepository.sendImageLocationMessage(
        images: [images!],
        location: ChatGeolocationDto(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
        message: messageText,
      );
    } else if (images != null) {
      return widget.chatRepository.sendImageMessage(
        images: [images!],
        message: messageText,
      );
    } else if (isLocationMessage) {
      final location = await widget.locationRepository.determinePosition();

      return widget.chatRepository.sendGeolocationMessage(
        location: ChatGeolocationDto(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
        message: messageText,
      );
    } else {
      return widget.chatRepository.sendMessage(
        messageText,
      );
    }
  }

  Future<void> _onGeoPressed() async {
    setState(() {
      isLocationMessage = !isLocationMessage;
    });
  }

  Future<void> _onImagePressed() async {
    setState(() {
      isImageSaving = !isImageSaving;
    });
  }
}

class _ChatBody extends StatelessWidget {
  final Iterable<ChatMessageDto> messages;

  const _ChatBody({
    required this.messages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (_, index) => _ChatMessage(
        chatData: messages.elementAt(index),
      ),
    );
  }
}

class _ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSendPressed;
  final bool isLocationMessage;
  final bool isImageSaving;
  final VoidCallback onGeoPressed;
  final VoidCallback onImagePressed;

  const _ChatTextField({
    required this.controller,
    required this.onSendPressed,
    required this.isLocationMessage,
    required this.onGeoPressed,
    required this.isImageSaving,
    required this.onImagePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.padding.bottom + 8,
          left: 8,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onImagePressed,
              icon: Icon(
                isImageSaving ? Icons.image : Icons.text_fields,
                color: colorScheme.onSurface,
              ),
            ),
            IconButton(
              onPressed: onGeoPressed,
              icon: Icon(
                Icons.place,
                color: isLocationMessage ? Colors.blue : Colors.black,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText:
                      isImageSaving ? "Ссылка на изображение" : "Сообщение",
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                onSendPressed(controller.text);
                controller.clear();
              },
              icon: Icon(
                isImageSaving ? Icons.save_as : Icons.send,
              ),
              color: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;
  final String topicName;

  const _ChatAppBar({
    required this.onUpdatePressed,
    required this.topicName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [IconButton(
        onPressed: onUpdatePressed,
        icon: const Icon(Icons.refresh),
      ),],
      title: Center(child: Text(topicName)),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessageDto chatData;

  const _ChatMessage({
    required this.chatData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chatData.chatUserDto is! ChatUserLocalDto) ...[_ChatAvatar(userData: chatData.chatUserDto),
            const SizedBox(
              width: 8,
            ),],
          Expanded(
            child: Material(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: chatData.chatUserDto is ChatUserLocalDto
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
                bottomRight: chatData.chatUserDto is ChatUserLocalDto
                    ? const Radius.circular(0)
                    : const Radius.circular(16),
              ),
              color: chatData.chatUserDto is ChatUserLocalDto
                  ? Colors.black38
                  : Colors.white38,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      chatData.chatUserDto.name ?? 'anon',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(chatData.message ?? ''),
                    if (chatData is ChatMessageImageDto ||
                        chatData is ChatMessageImageLocationDto) ...[
                      Wrap(
                        children: getListOfImeges(chatData),
                      )
                    ],
                    if (chatData is ChatMessageGeolocationDto ||
                        chatData is ChatMessageImageLocationDto) ...[
                      TextButton(
                        onPressed: () async {
                          goToMapLocation(chatData);
                        },
                        child: const Text(
                            "нажмите, чтобы отобразить геолокацию места"),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
          if (chatData.chatUserDto is ChatUserLocalDto) ...[
            const SizedBox(
              width: 8,
            ),
            _ChatAvatar(userData: chatData.chatUserDto),],
        ],
      ),
    );
  }
}

List<Widget> getListOfImeges(ChatMessageDto dto) {
  if (dto is ChatMessageImageDto) {
    return dto.images.urls.map((url) => Image.network(url)).toList();
  } else if (dto is ChatMessageImageLocationDto) {
    return dto.images.urls.map((url) => Image.network(url)).toList();
  } else {
    return [];
  }
}

void goToMapLocation(ChatMessageDto dto) async {
  final availableMaps = await MapLauncher.installedMaps;

  if (dto is ChatMessageGeolocationDto) {
    await availableMaps.first.showMarker(
      coords: Coords(dto.location.latitude, dto.location.longitude),
      title: "Ocean Beach",
    );
  } else if (dto is ChatMessageImageLocationDto) {
    await availableMaps.first.showMarker(
      coords: Coords(dto.location.latitude, dto.location.longitude),
      title: "Ocean Beach",
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  static const double _size = 42;

  final ChatUserDto userData;

  const _ChatAvatar({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('${userData.name!.split(' ').first[0]}${userData.name!.split(' ').last[0]}');
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        // color: colorScheme.primary,
        color: userData.name != null
            ? ColorUtils.stringToColor(userData.name!)
            : colorScheme.primary,
        shape: const CircleBorder(),
        child: Center(
          child: Text(
            userData.name != null
                ? '${userData.name!.split(' ').first[0]}${userData.name!.split(' ')[1][0]}'
                : '',
            //   style: TextStyle(
            //     color: colorScheme.onPrimary,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 24,
            //   ),
          ),
        ),
      ),
    );
  }
}
