class PixabayImage {
  final String imageUrl;
  final int likes;
  final int views;

  PixabayImage({required this.imageUrl, required this.likes, required this.views});

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      imageUrl: json['webformatURL'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}