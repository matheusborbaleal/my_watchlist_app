import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'mock_http_client.dart';

import 'package:my_watchlist_app/services/tmdb_api_service.dart';
import 'package:my_watchlist_app/services/places_api_service.dart';
import 'package:my_watchlist_app/models/cinema.dart';

@GenerateMocks([http.Client])
void main() {
  group('Cinema Model Tests', () {
    test('fromJson creates Cinema object correctly with all fields', () {
      final Map<String, dynamic> json = {
        'place_id': '123',
        'name': 'Great Cinema',
        'vicinity': 'Main Street, 100',
        'rating': 4.7,
        'photos': [
          {'photo_reference': 'ref_photo_1'},
        ],
        'geometry': {
          'location': {'lat': 1.0, 'lng': 2.0},
        },
      };

      final cinema = Cinema.fromJson(json);

      expect(cinema.id, '123');
      expect(cinema.name, 'Great Cinema');
      expect(cinema.address, 'Main Street, 100');
      expect(cinema.rating, 4.7);
      expect(cinema.photoReference, 'ref_photo_1');
      expect(cinema.latitude, 1.0);
      expect(cinema.longitude, 2.0);
    });

    test(
      'fromJson creates Cinema object with default values for optional fields',
      () {
        final Map<String, dynamic> json = {
          'place_id': '456',
          'name': 'Simple Cinema',
          'vicinity': 'Another Street',
          'geometry': {
            'location': {'lat': 3.0, 'lng': 4.0},
          },
        };

        final cinema = Cinema.fromJson(json);

        expect(cinema.id, '456');
        expect(cinema.name, 'Simple Cinema');
        expect(cinema.address, 'Another Street');
        expect(cinema.rating, 0.0);
        expect(cinema.photoReference, isNull);
        expect(cinema.latitude, 3.0);
        expect(cinema.longitude, 4.0);
      },
    );

    test('fromJson handles empty photos array', () {
      final Map<String, dynamic> json = {
        'place_id': '789',
        'name': 'Empty Photos Cinema',
        'vicinity': 'Empty Road',
        'photos': [],
        'geometry': {
          'location': {'lat': 5.0, 'lng': 6.0},
        },
      };

      final cinema = Cinema.fromJson(json);

      expect(cinema.photoReference, isNull);
    });

    test('fromJson handles different address keys (formatted_address)', () {
      final Map<String, dynamic> json = {
        'place_id': 'abc',
        'name': 'Formatted Address Cinema',
        'formatted_address': 'Complex Address, City, Country',
        'geometry': {
          'location': {'lat': 7.0, 'lng': 8.0},
        },
      };

      final cinema = Cinema.fromJson(json);

      expect(cinema.address, 'Complex Address, City, Country');
    });
  });

  group('TmdbApiService Tests', () {
    late MockHttpClient mockClient;
    late TmdbApiService tmdbApiService;

    setUp(() {
      mockClient = MockHttpClient.fromResponse(
        json.encode({'results': []}),
        200,
      );
      tmdbApiService = TmdbApiService(client: mockClient);
    });

    test(
      'searchMedia returns list of TmdbItem on successful API response',
      () async {
        mockClient = MockHttpClient.fromResponse(
          json.encode({
            'results': [
              {
                'id': 1,
                'title': 'Movie A',
                'media_type': 'movie',
                'poster_path': '/a.jpg',
                'overview': 'Desc A',
                'release_date': '2023-01-01',
              },
              {
                'id': 2,
                'name': 'Series B',
                'media_type': 'tv',
                'poster_path': '/b.jpg',
                'overview': 'Desc B',
                'first_air_date': '2022-01-01',
              },
            ],
          }),
          200,
        );
        tmdbApiService = TmdbApiService(client: mockClient);

        final result = await tmdbApiService.searchMedia('test query');

        expect(result, isA<List<TmdbItem>>());
        expect(result.length, 2);
        expect(result[0].title, 'Movie A');
        expect(result[1].title, 'Series B');
      },
    );

    test(
      'searchMedia returns empty list on HTTP error (e.g., 500 Server Error)',
      () async {
        mockClient = MockHttpClient.fromResponse('Server Error', 500);
        tmdbApiService = TmdbApiService(client: mockClient);

        final result = await tmdbApiService.searchMedia('test query');

        expect(result, isEmpty);
      },
    );

    test('searchMedia returns empty list on network error', () async {
      mockClient = MockHttpClient.fromException(Exception('Network is down'));
      tmdbApiService = TmdbApiService(client: mockClient);

      final result = await tmdbApiService.searchMedia('test query');

      expect(result, isEmpty);
    });

    test('searchMedia returns empty list for empty query', () async {
      final result = await tmdbApiService.searchMedia('');
      expect(result, isEmpty);
    });

    test('getFullImageUrl returns correct URL for valid path', () {
      final url = tmdbApiService.getFullImageUrl('/poster.jpg');
      expect(url, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('getFullImageUrl returns placeholder for null poster path', () {
      final url = tmdbApiService.getFullImageUrl(null);
      expect(url, 'https://via.placeholder.com/150x225?text=Sem+Poster');
    });

    test('getFullImageUrl returns placeholder for empty poster path', () {
      final url = tmdbApiService.getFullImageUrl('');
      expect(url, 'https://via.placeholder.com/150x225?text=Sem+Poster');
    });
  });

  group('PlacesApiService Tests', () {
    late MockHttpClient mockClient;
    late PlacesApiService placesApiService;

    setUp(() {
      mockClient = MockHttpClient.fromResponse(
        json.encode({'results': []}),
        200,
      );
      placesApiService = PlacesApiService(client: mockClient);
    });

    test(
      'searchNearbyCinemas returns list of Cinemas on successful API response',
      () async {
        mockClient = MockHttpClient.fromResponse(
          json.encode({
            'results': [
              {
                'place_id': '1',
                'name': 'Cinema 1',
                'vicinity': 'Address 1',
                'rating': 4.0,
                'geometry': {
                  'location': {'lat': 10.0, 'lng': 20.0},
                },
              },
              {
                'place_id': '2',
                'name': 'Cinema 2',
                'vicinity': 'Address 2',
                'rating': 3.5,
                'photos': [
                  {'photo_reference': 'photo_ref_abc'},
                ],
                'geometry': {
                  'location': {'lat': 11.0, 'lng': 21.0},
                },
              },
            ],
          }),
          200,
        );
        placesApiService = PlacesApiService(client: mockClient);

        final result = await placesApiService.searchNearbyCinemas(1.0, 1.0);

        expect(result, isA<List<Cinema>>());
        expect(result.length, 2);
        expect(result[0].name, 'Cinema 1');
        expect(result[0].latitude, 10.0);
        expect(result[0].longitude, 20.0);
        expect(result[1].name, 'Cinema 2');
        expect(result[1].address, 'Address 2');
        expect(result[1].latitude, 11.0);
        expect(result[1].longitude, 21.0);
      },
    );

    test(
      'searchNearbyCinemas returns empty list on HTTP error (e.g., 500 Server Error)',
      () async {
        mockClient = MockHttpClient.fromResponse('Server Error', 500);
        placesApiService = PlacesApiService(client: mockClient);

        final result = await placesApiService.searchNearbyCinemas(1.0, 1.0);

        expect(result, isEmpty);
      },
    );

    test('searchNearbyCinemas returns empty list on network error', () async {
      mockClient = MockHttpClient.fromException(Exception('Network is down'));
      placesApiService = PlacesApiService(client: mockClient);

      final result = await placesApiService.searchNearbyCinemas(1.0, 1.0);

      expect(result, isEmpty);
    });

    test(
      'searchNearbyCinemas returns empty list if no results are found',
      () async {
        mockClient = MockHttpClient.fromResponse(
          json.encode({'results': []}),
          200,
        );
        placesApiService = PlacesApiService(client: mockClient);

        final result = await placesApiService.searchNearbyCinemas(1.0, 1.0);

        expect(result, isEmpty);
      },
    );

    test('getPhotoUrl returns correct URL for valid photo reference', () {
      final url = placesApiService.getPhotoUrl('test_photo_ref');
      expect(
        url,
        startsWith('https://maps.googleapis.com/maps/api/place/photo'),
      );
      expect(url, contains('photoreference=test_photo_ref'));
    });

    test('getPhotoUrl returns null for null photo reference', () {
      final url = placesApiService.getPhotoUrl(null);
      expect(url, isNull);
    });

    test('getPhotoUrl returns null for empty photo reference', () {
      final url = placesApiService.getPhotoUrl('');
      expect(url, isNull);
    });
  });
}
