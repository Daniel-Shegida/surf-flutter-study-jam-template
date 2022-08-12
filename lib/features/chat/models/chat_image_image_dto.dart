/// Data transfer object representing images.
class ChatImageDto {
  /// image urls
  final List<String> urls;

  /// Constructor for [ChatImageDto].
  ChatImageDto({
    required this.urls,
  });

  @override
  String toString() => 'ChatGeolocationDto(urls: $urls)';
}
