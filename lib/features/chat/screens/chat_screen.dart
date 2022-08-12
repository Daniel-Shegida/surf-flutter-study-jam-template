import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_image_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_location_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_messsage_image_location_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/storage/repository/local_rep.dart';
import 'package:surf_practice_chat_flutter/features/utils/color_utils.dart';

/// Main screen of chat app, containing messages.
class ChatScreen extends StatefulWidget {
  /// Repository for chat functionality.
  final IChatRepository chatRepository;

  /// Constructor for [ChatScreen].
  const ChatScreen({
    required this.chatRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _nameEditingController = TextEditingController();

  late final LocalRepository _localRepository;

  Iterable<ChatMessageDto> _currentMessages = [];

  @override
  void initState() {
    super.initState();
    _localRepository = context.read<LocalRepository>();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _ChatAppBar(
          controller: _nameEditingController,
          onUpdatePressed: _onUpdatePressed,
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
          _ChatTextField(onSendPressed: _onSendPressed),
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
    final messages = await widget.chatRepository.sendMessage(messageText);
    setState(() {
      _currentMessages = messages;
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
  final ValueChanged<String> onSendPressed;

  final _textEditingController = TextEditingController();

  _ChatTextField({
    required this.onSendPressed,
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
          left: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Сообщение',
                ),
              ),
            ),
            IconButton(
              onPressed: () => onSendPressed(_textEditingController.text),
              icon: const Icon(Icons.send),
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
  final TextEditingController controller;

  const _ChatAppBar({
    required this.onUpdatePressed,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onUpdatePressed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ChatAvatar(userData: chatData.chatUserDto),
          SizedBox(width: 8,),
          Expanded(
            child: Material(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: chatData.chatUserDto is ChatUserLocalDto
                    ? Radius.circular(16)
      : Radius.circular(0),
                bottomRight: chatData.chatUserDto is ChatUserLocalDto
                    ? Radius.circular(0)
                    : Radius.circular(16),
              ),
              color: chatData.chatUserDto is ChatUserLocalDto
                  ? colorScheme.primary.withOpacity(.1)
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
                      // chatData.chatUserDto.name ?? '',
                      chatData.runtimeType.toString(),
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
                        child: Text("нажмите, чтобы отобразить геолокацию места"),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
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
                ? '${userData.name!.split(' ').first[0]}${userData.name!.split(' ').last[0]}'
                : '',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
