class ContratoModel {
  final String id;
  final String tipo; // "Venda" ou "Aluguel"
  final String status;
  final String dataInicio;
  final String valor;
  final String imovel;

  // 🔹 Novos campos opcionais (não obrigatórios)
  final String? proprietarioNome;
  final String? adquirenteNome;
  final String? corretorNome;

  const ContratoModel({
    required this.id,
    required this.tipo,
    required this.status,
    required this.dataInicio,
    required this.valor,
    required this.imovel,
    this.proprietarioNome,
    this.adquirenteNome,
    this.corretorNome,
  });

  factory ContratoModel.fromJson(Map<String, dynamic> json) {
    return ContratoModel(
      id: json['id'],
      tipo: json['tipo'],
      status: json['status'],
      dataInicio: json['dataInicio'],
      valor: json['valor'],
      imovel: json['imovel'],
      proprietarioNome: json['proprietarioNome'],
      adquirenteNome: json['adquirenteNome'],
      corretorNome: json['corretorNome'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'status': status,
        'dataInicio': dataInicio,
        'valor': valor,
        'imovel': imovel,
        'proprietarioNome': proprietarioNome,
        'adquirenteNome': adquirenteNome,
        'corretorNome': corretorNome,
      };
}
