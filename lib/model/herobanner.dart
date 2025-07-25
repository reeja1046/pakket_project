class HeroBanner {
  final String url;
  final String name;
  final String id;
  final String categoryname;

  HeroBanner({
    required this.url,
    required this.name,
    required this.id,
    required this.categoryname,
  });

  factory HeroBanner.fromJson(Map<String, dynamic> json) {
    print(json['categoryName']);
    return HeroBanner(
      url: json['banner']['url'],
      name: json['name'],
      id: json['categoryId'],
      categoryname: json['categoryName'],
    );
  }
}

//home ad banner
class HomeBanner {
  final String imageUrl;
  final String redirectUrl;

  HomeBanner({required this.imageUrl, required this.redirectUrl});

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      imageUrl: json['banner']['url'],
      redirectUrl: json['url'],
    );
  }
}

class HomeCheckoutBanner{
   final String imageUrl;
  final String redirectUrl;

  HomeCheckoutBanner({required this.imageUrl, required this.redirectUrl});

  factory HomeCheckoutBanner.fromJson(Map<String, dynamic> json) {
    return HomeCheckoutBanner(
      imageUrl: json['banner']['url'],
      redirectUrl: json['url'],
    );
  }
}
