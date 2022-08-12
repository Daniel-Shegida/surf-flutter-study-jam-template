import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chart_topics_repository.dart';

/// Screen, that is used for creating new chat topics.
class CreateTopicScreen extends StatefulWidget {
  /// Constructor for [CreateTopicScreen].
  const CreateTopicScreen({required this.topicRepository, Key? key}) : super(key: key);

  final IChatTopicsRepository topicRepository;

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  late final TextEditingController _topicNameController;
  late final TextEditingController _topicDescController;

  @override
  void initState() {
    super.initState();
    _topicNameController = TextEditingController();
    _topicDescController = TextEditingController();
  }

  @override
  void dispose() {
    _topicNameController.dispose();
    _topicDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: _CreateTopicAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _NameInputField(
                controller: _topicNameController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _DescriptionInputField(
                controller: _topicDescController,
              ),
            ), // _ChatTextField(onSendPressed: _onSendPressed),utt
            _CreatingButton(
              onPressed: () {
                _finishCreating(
                  _topicNameController.text,
                  _topicDescController.text,
                  context,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _finishCreating(
    String name,
    String description,
    BuildContext context,
  ) {
    _createTopic(name, description);

    Navigator.of(context).pop();
  }

  void _createTopic(
    String name,
    String description,
  ) async {
    await widget.topicRepository.createTopic(
      ChatTopicSendDto(name: name, description: description),
    );
  }
}

class _CreateTopicAppBar extends StatelessWidget {
  const _CreateTopicAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(
        child: Text('Создание топика'),
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({required this.controller, Key? key}) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.account_box),
        labelText: 'Название',
        border: OutlineInputBorder(borderSide: BorderSide()),
      ),
    );
  }
}

class _DescriptionInputField extends StatelessWidget {
  const _DescriptionInputField({required this.controller, Key? key})
      : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.add_chart),
        labelText: 'Описание',
        border: OutlineInputBorder(borderSide: BorderSide()),
      ),
    );
  }
}

class _CreatingButton extends StatelessWidget {
  const _CreatingButton({required this.onPressed, Key? key}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.lightGreenAccent,
      onPressed: onPressed,
      child: const Text("Создать"),
    );
  }
}
