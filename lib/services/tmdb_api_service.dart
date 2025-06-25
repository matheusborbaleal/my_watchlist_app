import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final String? releaseDate;

  TmdbItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    this.releaseDate,
  });

  factory TmdbItem.fromJson(Map<String, dynamic> json) {
    return TmdbItem(
      id: json['id'] as int,
      title:
          json['title'] as String? ??
          json['name'] as String? ??
          'Título Desconhecido',
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String?,
      releaseDate:
          json['release_date'] as String? ?? json['first_air_date'] as String?,
    );
  }
}

class TmdbApiService {
  static const String _apiKey = '1a552f886256fd7b40b2d7c56f624bd3';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _baseImageUrl = 'https://image.tmdb.org/t/p/w500';

  final http.Client _client;

  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<TmdbItem>> searchMedia(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search/multi?api_key=$_apiKey&query=$query&language=pt-BR',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results
            .where(
              (item) =>
                  item['media_type'] == 'movie' || item['media_type'] == 'tv',
            )
            .map((item) => TmdbItem.fromJson(item))
            .toList();
      } else {
        print('Erro na requisição TMDB: ${response.statusCode}');
        print('Corpo da resposta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro de conexão TMDB: $e');
      return [];
    }
  }

  String getFullImageUrl(String? posterPath) {
    if (posterPath == null || posterPath.isEmpty) {
      return 'https://via.placeholder.com/150x225?text=Sem+Poster';
    }
    return '$_baseImageUrl$posterPath';
  }
}
