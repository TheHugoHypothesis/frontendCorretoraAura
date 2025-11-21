class PagamentoModel {
  // Identificadores
  final String codigoContrato;
  final int numeroPagamento;

  // Valores e Datas
  final double valor;
  final DateTime dataVencimento;
  final DateTime dataPagamento;

  // Status e Tipos
  final String status; // Ex: "pago", "pendente"
  final String formaPagamento; // Ex: "boleto", "pix"
  final String tipo; // Ex: "aluguel", "multa"

  const PagamentoModel({
    required this.codigoContrato,
    required this.numeroPagamento,
    required this.valor,
    required this.dataVencimento,
    required this.dataPagamento,
    required this.status,
    required this.formaPagamento,
    required this.tipo,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo_contrato': codigoContrato,
      'n_pagamento': numeroPagamento,
      'valor': valor,
      'data_vencimento': dataVencimento.toIso8601String().split('T').first,
      'data_pagamento': dataPagamento.toIso8601String().split('T').first,
      'status': status,
      'forma_pagamento': formaPagamento,
      'tipo': tipo,
    };
  }

  // ---------------------------------------------------------
  // DESSERIALIZAÇÃO: JSON -> Model (Para receber do Backend)
  // ---------------------------------------------------------
  factory PagamentoModel.fromJson(Map<String, dynamic> json) {
    return PagamentoModel(
      codigoContrato: json['codigo_contrato']?.toString() ?? '',
      numeroPagamento: json['n_pagamento'] is int
          ? json['n_pagamento']
          : int.tryParse(json['n_pagamento'].toString()) ?? 1,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      dataVencimento:
          DateTime.tryParse(json['data_vencimento'] ?? '') ?? DateTime.now(),
      dataPagamento:
          DateTime.tryParse(json['data_pagamento'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pendente',
      formaPagamento: json['forma_pagamento'] ?? '',
      tipo: json['tipo'] ?? 'aluguel',
    );
  }
}
