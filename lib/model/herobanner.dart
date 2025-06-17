class HeroBanner {
  final String url;
  final String name;
  final String route;

  HeroBanner({
    required this.url,
    required this.name,
    required this.route,
  });

  factory HeroBanner.fromJson(Map<String, dynamic> json) {
    return HeroBanner(
      url: json['banner']['url'],
      name: json['name'],
      route: json['route'],
    );
  }
}
