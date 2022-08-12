import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/location_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/storage/repository/local_rep.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chart_topics_repository.dart';
import 'package:surf_practice_chat_flutter/features/topics/screens/create_topic_screen.dart';
import 'package:surf_practice_chat_flutter/features/utils/color_utils.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Screen with different chat topics to go to.
class TopicsScreen extends StatefulWidget {
  final IChatTopicsRepository topicRepository;

  /// Constructor for [TopicsScreen].
  const TopicsScreen({required this.topicRepository, Key? key})
      : super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Iterable<ChatTopicDto> _currentTopics = [];

  @override
  void initState() {
    _loadData();
    super.initState();
    // _localRepository = context.read<LocalRepository>();
  }

  void _loadData() async {
    final topics = await widget.topicRepository.getTopics(
      topicsStartDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
    );
    setState(() {
      _currentTopics = topics;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<CreateTopicScreen>(
            context,
            MaterialPageRoute(
              builder: (_) {
                return CreateTopicScreen(
                  topicRepository: widget.topicRepository,
                );
              },
            ),
          );
        },
      ),
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _TopicAppBar(
          onUpdatePressed: _loadData,
          // _onUpdatePressed,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _TopicBody(topics: _currentTopics),
          ),
        ],
      ),
    );
  }
}

class _TopicBody extends StatelessWidget {
  final Iterable<ChatTopicDto> topics;

  const _TopicBody({
    required this.topics,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (_, index) => _Topic(
        topicData: topics.elementAt(index),
      ),
    );
  }
}

class _TopicAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;

  const _TopicAppBar({
    required this.onUpdatePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: onUpdatePressed,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: Center(
          child: Text(context.read<LocalRepository>().getUserName() ?? "Anon")),
    );
  }
}

class _Topic extends StatelessWidget {
  final ChatTopicDto topicData;

  const _Topic({
    required this.topicData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(18.0),
        child: InkWell(
          onTap: () {
            final token = context.read<LocalRepository>().getToken();
            Navigator.push<ChatScreen>(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return ChatScreen(
                    topicName: topicData.name ?? "",
                    chatRepository: ChatRepository(
                      StudyJamClient().getAuthorizedClient(token.token),
                      topicData.id,
                    ),
                    locationRepository: LocationRepository(),
                  );
                },
              ),
            );
          },
          child: Card(
            child: ListTile(
              leading: _ChatAvatar(
                userData: topicData,
              ),
              title: Text(topicData.name ?? ""),
              subtitle: Text(
                topicData.id.toString(),
              ),
            ),
          ),
        ));
  }
}

class _ChatAvatar extends StatelessWidget {
  static const double _size = 42;

  final ChatTopicDto userData;

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
        color: userData.name != null
            ? ColorUtils.stringToColor(userData.name!)
            : colorScheme.primary,
        shape: const CircleBorder(),
        child: Center(
          child: Text(
            (userData.name != null && userData.name != '')
                ? userData.name!.split(' ').first[0]
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
