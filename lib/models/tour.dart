class Tour {
  final String? id;
  final String title;
  final int price;
  final String location;
  final String image;
  final String description;
  String status; // current/next/past/wishlist

  Tour({
    this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.image,
    required this.description,
    this.status = 'Next',
  });

  Tour copyWith({
    String? id,
    String? title,
    int? price,
    String? location,
    String? image,
    String? description,
    String? status,
  }) {
    return Tour(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      location: location ?? this.location,
      image: image ?? this.image,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toInt() : 0,
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Next',
    );
  }
}