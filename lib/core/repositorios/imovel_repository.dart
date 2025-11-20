import 'dart:convert';
import '../api/api_client.dart';
import '../api/endpoints.dart';

import '../../data/models/imovel_model.dart';

class ImovelRepository {
  final ApiClient _apiClient = ApiClient();

  static const Map<String, String> _filterKeyMap = {
    'valorMin': 'valor_venal_min',
    'valorMax': 'valor_venal_max',
    'metragemMin': 'metragem_min',
    'metragemMax': 'metragem_max',
    'numQuartos': 'n_quartos',
    'numReformas': 'n_reformas',
    'possuiGaragem': 'possui_garagem',
    'mobiliado': 'mobiliado',
    'proprietarioCpf': 'cpf',
    'matricula': 'matricula',
    'tipo': 'tipo',
    'finalidade': 'finalidade',
    'comodidades': 'comodidade',
    'bairro': 'bairro',
    'cidade': 'cidade',
    'cep': 'cep',
    'logradouro': 'logradouro',
  };

  Future<List<ImovelModel>> filtrarImoveis(Map<String, dynamic> filters) async {
    final Map<String, dynamic> queryParams = {};

    filters.forEach((key, value) {
      if (value != null) {
        if (value is String && value.isEmpty) return;

        final backendKey = _filterKeyMap[key] ?? key;

        if (key == 'comodidades' && value is Map) {
          final activeAmenities = (value as Map<String, bool>)
              .entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .join(',');

          if (activeAmenities.isNotEmpty) {
            queryParams[backendKey] = activeAmenities;
          }
        } else if (value is bool) {
          if (value == true) queryParams[backendKey] = 'true';
        } else {
          queryParams[backendKey] = value.toString();
        }
      }
    });

    final responseData = await _apiClient.get(
      Endpoints.imoveisFilters,
      queryParams: queryParams,
      requireAuth: false, // Busca costuma ser pública, ou mude para true
    );

    // 3. Mapeia a resposta
    if (responseData is List) {
      return responseData
          .map((json) => ImovelModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Caso a API retorne algo que não é uma lista (ex: Map vazio por erro)
      return [];
    }
  }
}
