class Model {
  String url;
  String title;
  String icon;
  int is_on;




  // Constructor
  Model({
    required this.url,
    required this.title,
    required this.icon,
    required this.is_on,

  });

  // Factory method to create a Model from JSON
  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      url: json['url'], // id is now a String
      title: json['title'],
      icon: json['icon'],
      is_on: json['is_on'] ,

    );
  }

  // Method to convert Model instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url, // id is now a String
      'title': title,
      'icon': icon,
      'is_on': is_on,
    };
  }
}


