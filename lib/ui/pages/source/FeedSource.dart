// feed_source.dart

class FeedSource {
  final String title;
  final String url;
  final String icon;
  bool is_on=false;

  FeedSource({required this.title, required this.url, required this.icon,required this.is_on});

  factory FeedSource.fromJson(Map<String, dynamic> json) {
    return FeedSource(
      title: json['title'],
      url: json['url'],
      icon: json['icon'],
      is_on: false,
    );
  }

  void setIsOn(bool is_on_new) {
    is_on = is_on_new;
  }
}