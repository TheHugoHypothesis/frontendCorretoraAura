class ContratoModel {
  final String id;
  final String tipo; // Venda ou Aluguel
  final String status;
  final String dataInicio;
  final String valor;
  final String imovel;

  const ContratoModel({
    required this.id,
    required this.tipo,
    required this.status,
    required this.dataInicio,
    required this.valor,
    required this.imovel,
  });
}
