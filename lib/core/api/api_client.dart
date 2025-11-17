import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';
import 'dart:io';

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> get(String endpoint,
      {bool requireAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    final response = await http.get(url, headers: headers);
    return await _handleResponse(
        response, () => get(endpoint, requireAuth: requireAuth));
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = false, bool isLoginRoute = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    print('--- INÍCIO LOG REQUISIÇÃO ---');
    print('>>> REQ POST para: $endpoint');
    print('>>> JSON ENVIADO: ${json.encode(body)}');
    print('----------------------------');

    final response =
        await http.post(url, headers: headers, body: json.encode(body));
    return await _handleResponse(
        response,
        () => post(endpoint, body,
            requireAuth: requireAuth, isLoginRoute: isLoginRoute),
        isLoginRoute: isLoginRoute);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = true}) async {
    // PUTs geralmente requerem autenticação
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    final response =
        await http.put(url, headers: headers, body: json.encode(body));
    return await _handleResponse(
        // Adiciona a função de retry para renovar o token em caso de 401
        response,
        () => put(endpoint, body, requireAuth: requireAuth));
  }

  Future<Map<String, dynamic>> delete(String endpoint,
      {bool requireAuth = true}) async {
    // DELETEs geralmente requerem autenticação
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    final response = await http.delete(url, headers: headers);
    return await _handleResponse(
        response, () => delete(endpoint, requireAuth: requireAuth));
  }

  Future<Map<String, dynamic>> uploadFile(String endpoint, File file,
      {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    final headers = await _buildHeaders(requireAuth);
    request.headers.addAll(headers);

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_image_url',
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return await _handleResponse(
        response, () => uploadFile(endpoint, file, requireAuth: requireAuth));
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

  Future<Map<String, dynamic>> _handleResponse(
      http.Response response, Future<Map<String, dynamic>> Function() retryFn,
      {bool isLoginRoute = false}) async {
    print('--- INÍCIO LOG RESPOSTA ---');
    print('<<< ENDPOINT: ${response.request!.url.path}');
    print('<<< STATUS CODE: ${response.statusCode}');
    print('<<< CORPO BRUTO RECEBIDO: ${response.body}');
    print('----------------------------');

    if (response.statusCode == 401) {
      if (isLoginRoute) {
        throw Exception('Credenciais inválidas. Verifique CPF e senha.');
      }

      final refreshed = await TokenManager.refreshAccessToken();
      if (refreshed) return await retryFn();
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else {
      String defaultMessage =
          'Erro ${response.statusCode}: Falha na requisição.';
      String specificMessage = defaultMessage;

      try {
        if (response.body.isNotEmpty) {
          final errorData = json.decode(response.body);

          if (errorData.containsKey('message')) {
            specificMessage = errorData['message'].toString();
          } else if (errorData.containsKey('error')) {
            specificMessage = errorData['error'].toString();
          } else {
            specificMessage = response.body;
          }
        }
      } catch (e) {
        specificMessage = defaultMessage;
      }

      throw Exception(specificMessage);
    }
  }
}
