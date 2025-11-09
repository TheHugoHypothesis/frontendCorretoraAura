import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

class ApiClient {
  static const String baseUrl = 'https://sua-corretora-api.com/v1';

  Future<Map<String, dynamic>> get(String endpoint,
      {bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    final response = await http.get(url, headers: headers);
    return await _handleResponse(
        response, () => get(endpoint, requireAuth: requireAuth));
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    final response =
        await http.post(url, headers: headers, body: json.encode(body));
    return await _handleResponse(
        response, () => post(endpoint, body, requireAuth: requireAuth));
  }

  // --- helpers ---

  Future<Map<String, String>> _buildHeaders(bool requireAuth) async {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await TokenManager.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response,
      Future<Map<String, dynamic>> Function() retryFn) async {
    if (response.statusCode == 401) {
      final refreshed = await TokenManager.refreshAccessToken();
      if (refreshed) return await retryFn();
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.body}');
    }
  }
}
