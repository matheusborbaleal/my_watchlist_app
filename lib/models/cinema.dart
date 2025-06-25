class Cinema {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String? photoReference;
  final double latitude;
  final double longitude;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    this.rating = 0.0,
    this.photoReference,
    required this.latitude,
    required this.longitude,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['place_id'] as String,
      name: json['name'] as String,
      address:
          json['vicinity'] as String? ??
          json['formatted_address'] as String? ??
          'Endereço Desconhecido',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      photoReference:
          (json['photos'] != null && (json['photos'] as List).isNotEmpty)
              ? json['photos'][0]['photo_reference'] as String?
              : null,
      latitude: json['geometry']['location']['lat'] as double,
      longitude: json['geometry']['location']['lng'] as double,
    );
  }
}
