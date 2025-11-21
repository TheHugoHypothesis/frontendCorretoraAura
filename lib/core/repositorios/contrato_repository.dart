import 'package:aura_frontend/core/api/api_client.dart';
import 'package:aura_frontend/core/api/endpoints.dart';
import '../../data/models/contrato_model.dart';

class ContratosRepository {
  final ApiClient _apiClient = ApiClient();

  Future<int?> cadastrarContrato(ContratoModel contrato) async {
    final Map<String, dynamic> body = Map.from(contrato.toJson());
    body.remove('codigo');

    try {
      final response = await _apiClient.post(
        Endpoints.contratoCadastro,
        body,
        requireAuth: true,
      );

      if (response.containsKey('codigo')) {
        return response['codigo'] as int;
      }
      return null;
    } catch (e) {
      throw Exception("Falha ao criar contrato: $e");
    }
  }

  Future<void> deletarContrato(String codigo) async {
    try {
      await _apiClient.delete(
        Endpoints.contratoDeletar,
        queryParams: {'codigo': codigo},
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao deletar contrato: $e");
    }
  }

  Future<void> alterarStatus(String codigo, String novoStatus) async {
    try {
      await _apiClient.put(
        Endpoints.contratoAlterarStatus,
        {
          "codigo": codigo,
          "status": novoStatus,
        },
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao alterar status: $e");
    }
  }

  Future<List<dynamic>> getContratosNoPrazo() async {
    final response = await _apiClient.get(
      Endpoints.contratoPrazo,
      requireAuth: true,
    );
    // Retorna a lista crua ou mapeia para Model
    return response is List ? response : [];
  }

  /// Contratos de Aluguel Ativos
  Future<List<ContratoModel>> getAlugueisAtivos() async {
    final response = await _apiClient.get(
      Endpoints.contratoAluguelAtivo,
      requireAuth: true,
    );
    if (response is List) {
      return response.map((j) => ContratoModel.fromJson(j)).toList();
    }
    return [];
  }

  Future<List<dynamic>> getHistoricoPessoasImovel(String matricula) async {
    final response = await _apiClient.get(
      Endpoints.contratoPessoasImovel,
      queryParams: {'matricula': matricula},
      requireAuth: true,
    );
    return response is List ? response : [];
  }

  Future<List<dynamic>> getValoresImovel(String matricula) async {
    final response = await _apiClient.get(
      Endpoints.contratoValoresImovel,
      queryParams: {'matricula': matricula},
      requireAuth: true,
    );
    return response is List ? response : [];
  }
}
