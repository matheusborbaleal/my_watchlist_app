import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MockHttpClient extends MockClient {
  MockHttpClient(
    Future<http.Response> Function(http.Request request) mockResponse,
  ) : super((request) => mockResponse(request));

  static MockHttpClient fromResponse(
    String body,
    int statusCode, {
    Map<String, String>? headers,
  }) {
    return MockHttpClient((request) async {
      return http.Response(body, statusCode, headers: headers ?? {});
    });
  }

  static MockHttpClient fromException(Exception exception) {
    return MockHttpClient((request) async {
      throw exception;
    });
  }
}
