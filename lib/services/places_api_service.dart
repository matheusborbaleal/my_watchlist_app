import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_watchlist_app/models/cinema.dart';

class PlacesApiService {
  static const String _apiKey = 'AIzaSyCzA43Z4Wu9O7VXK9vXYvyZEJ-Ja2D0bnI';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _photoBaseUrl =
      'https://maps.googleapis.com/maps/api/place/photo';

  final http.Client _client;

  PlacesApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Cinema>> searchNearbyCinemas(
    double latitude,
    double longitude, {
    double radius = 5000,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=movie_theater&key=$_apiKey&language=pt-BR',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results.map((json) => Cinema.fromJson(json)).toList();
      } else {
        print('Erro na requisição Places API: ${response.statusCode}');
        print('Corpo da resposta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro de conexão Places API: $e');
      return [];
    }
  }

  String? getPhotoUrl(String? photoReference, {int maxWidth = 400}) {
    if (photoReference == null || photoReference.isEmpty) {
      return null;
    }
    return '$_photoBaseUrl?maxwidth=$maxWidth&photoreference=$photoReference&key=$_apiKey';
  }
}
