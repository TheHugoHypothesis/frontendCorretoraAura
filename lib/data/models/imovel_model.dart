import 'package:aura_frontend/data/models/contrato_model.dart';

class ImovelModel {
  final String matricula;
  final String endereco;
  final String statusOcupacao; // Ex: "Alugado", "Vendido", "Disponível"
  final String valorVenal;
  final List<ContratoModel> contratos; // Contratos relacionados a este imóvel

  const ImovelModel({
    required this.matricula,
    required this.endereco,
    required this.statusOcupacao,
    required this.valorVenal,
    required this.contratos,
  });
}
