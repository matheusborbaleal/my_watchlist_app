import 'package:cloud_firestore/cloud_firestore.dart';

class MovieSeries {
  final String id;
  final String title;
  final String? posterUrl;
  final String? overview;
  final DateTime? releaseDate;
  bool watched;

  MovieSeries({
    required this.id,
    required this.title,
    this.posterUrl,
    this.overview,
    this.releaseDate,
    this.watched = false,
  });

  factory MovieSeries.fromFirestore(Map<String, dynamic> data, String id) {
    return MovieSeries(
      id: id,
      title: data['title'] as String,
      posterUrl: data['posterUrl'] as String?,
      overview: data['overview'] as String?,
      releaseDate:
          (data['releaseDate'] != null)
              ? (data['releaseDate'] as Timestamp).toDate()
              : null,
      watched: data['watched'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'posterUrl': posterUrl,
      'overview': overview,
      'releaseDate':
          releaseDate != null ? Timestamp.fromDate(releaseDate!) : null,
      'watched': watched,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
