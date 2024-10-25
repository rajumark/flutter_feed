// feed_source.dart

class FeedSource {
  final String title;
  final String url;
  final String icon;

  FeedSource({required this.title, required this.url, required this.icon});

  factory FeedSource.fromJson(Map<String, dynamic> json) {
    return FeedSource(
      title: json['title'],
      url: json['url'],
      icon: json['icon'],
    );
  }
}