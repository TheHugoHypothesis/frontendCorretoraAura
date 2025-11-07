class ContratoMock {
  final String id;
  final String tipo; // Venda ou Aluguel
  final String status;
  final String dataInicio;
  final String valor;
  final String imovel;

  const ContratoMock({
    required this.id,
    required this.tipo,
    required this.status,
    required this.dataInicio,
    required this.valor,
    required this.imovel,
  });
}

class ImovelMock {
  final String matricula;
  final String endereco;
  final String statusOcupacao; // Ex: "Alugado", "Vendido", "Disponível"
  final String valorVenal;
  final List<ContratoMock> contratos; // Contratos relacionados a este imóvel

  const ImovelMock({
    required this.matricula,
    required this.endereco,
    required this.statusOcupacao,
    required this.valorVenal,
    required this.contratos,
  });
}
